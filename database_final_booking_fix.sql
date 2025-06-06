-- === STEP 1: Create the new table to store individual booked seats ===
-- This table will have a UNIQUE constraint to make it impossible for the
-- database to store the same seat for the same showtime twice.

CREATE TABLE IF NOT EXISTS public.showtime_seats (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  movie_id text NOT NULL,
  showtime timestamptz NOT NULL,
  seat_label text NOT NULL,
  ticket_id bigint, -- Can be null initially, updated after ticket is created
  created_at timestamptz DEFAULT now(),

  -- The MOST IMPORTANT part: A unique constraint on these three columns.
  CONSTRAINT unique_seat_per_showtime UNIQUE (movie_id, showtime, seat_label)
);

-- Add a foreign key constraint to the tickets table.
-- We add it here, but ensure your tickets table exists.
-- If this fails, you can run it separately after confirming the tickets table exists.
DO $$
BEGIN
   IF NOT EXISTS (
       SELECT 1 FROM pg_constraint
       WHERE conname = 'fk_ticket' AND conrelid = 'public.showtime_seats'::regclass
   ) THEN
       ALTER TABLE public.showtime_seats
       ADD CONSTRAINT fk_ticket
       FOREIGN KEY (ticket_id)
       REFERENCES public.tickets(id)
       ON DELETE SET NULL; -- If a ticket is deleted, just nullify the link.
   END IF;
END;
$$;


-- === STEP 2: Create the new, more robust booking function ===
-- This function will attempt to insert into the new table first.
-- If it fails due to the unique constraint, the booking is rejected.

CREATE OR REPLACE FUNCTION book_ticket_final(
    p_user_id uuid,
    p_user_email text,
    p_movie_id text,
    p_movie_title text,
    p_poster_url text,
    p_seats jsonb,
    p_total_amount numeric,
    p_date_time timestamptz,
    p_theater text
)
RETURNS json AS $$
DECLARE
    v_new_ticket_id bigint;
    v_seat_to_book text;
    v_temp_seat_ids bigint[] := ARRAY[]::bigint[];
    v_current_seat_id bigint;
BEGIN
    -- Loop through each seat the user wants to book.
    FOR v_seat_to_book IN SELECT jsonb_array_elements_text(p_seats)
    LOOP
        -- Try to insert the seat into our locking table.
        -- If the seat is already taken, the UNIQUE constraint will trigger an exception.
        INSERT INTO public.showtime_seats (movie_id, showtime, seat_label)
        VALUES (p_movie_id, p_date_time, v_seat_to_book)
        RETURNING id INTO v_current_seat_id;
        
        -- Store the temporary ID of the inserted seat lock.
        v_temp_seat_ids := array_append(v_temp_seat_ids, v_current_seat_id);
    END LOOP;

    -- If the loop completes without an exception, all seats were available.
    -- Now, create the main ticket.
    INSERT INTO public.tickets (user_id, user_email, movie_id, movie_title, poster_url, seats, total_amount, date_time, theater, status)
    VALUES (p_user_id, p_user_email, p_movie_id, p_movie_title, p_poster_url, p_seats, p_total_amount, p_date_time, p_theater, 'active')
    RETURNING id INTO v_new_ticket_id;

    -- Now that we have the ticket ID, update the seat lock records with it.
    UPDATE public.showtime_seats
    SET ticket_id = v_new_ticket_id
    WHERE id = ANY(v_temp_seat_ids);

    -- Return success.
    RETURN json_build_object('success', true, 'message', 'Đặt vé thành công!');

EXCEPTION
    -- This block catches errors, specifically the unique constraint violation.
    WHEN unique_violation THEN
        -- A seat was already booked. The transaction will automatically roll back.
        RETURN json_build_object('success', false, 'message', 'Rất tiếc, một hoặc nhiều ghế bạn chọn vừa được người khác đặt. Vui lòng chọn lại.');
    WHEN OTHERS THEN
        -- Catch any other unexpected errors.
        RETURN json_build_object('success', false, 'message', 'Đã xảy ra lỗi không mong muốn trong quá trình đặt vé.');
END;
$$ LANGUAGE plpgsql;


-- === STEP 3: Update the function to fetch booked seats ===
-- This function should now query the new `showtime_seats` table for better performance and accuracy.
CREATE OR REPLACE FUNCTION get_booked_seats(
    p_movie_id text,
    p_date_time timestamptz
)
RETURNS text[] AS $$
DECLARE
    v_booked_seats text[];
BEGIN
    SELECT array_agg(seat_label)
    INTO v_booked_seats
    FROM public.showtime_seats
    WHERE movie_id = p_movie_id AND showtime = p_date_time;

    IF v_booked_seats IS NULL THEN
        RETURN ARRAY[]::text[];
    END IF;

    RETURN v_booked_seats;
END;
$$ LANGUAGE plpgsql;
