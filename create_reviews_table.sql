-- Bảng để lưu trữ đánh giá của người dùng cho các bộ phim
CREATE TABLE public.reviews (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  movie_id text NOT NULL,
  user_id uuid NOT NULL,
  user_email text NOT NULL,
  user_avatar_url text,
  rating numeric NOT NULL,
  comment text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT reviews_pkey PRIMARY KEY (id),
  CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
