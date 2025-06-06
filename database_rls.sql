-- Kích hoạt Row Level Security cho bảng reviews
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Chính sách 1: Cho phép mọi người đọc tất cả các đánh giá
CREATE POLICY "Allow public read access"
ON public.reviews
FOR SELECT
USING (true);

-- Chính sách 2: Cho phép người dùng đã đăng nhập tạo đánh giá mới
CREATE POLICY "Allow authenticated users to insert"
ON public.reviews
FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

-- Chính sách 3: Cho phép người dùng cập nhật đánh giá của chính họ
CREATE POLICY "Allow users to update their own reviews"
ON public.reviews
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Chính sách 4: Cho phép người dùng xóa đánh giá của chính họ
CREATE POLICY "Allow users to delete their own reviews"
ON public.reviews
FOR DELETE
USING (auth.uid() = user_id);
