/*
  # 채팅 애플리케이션 스키마

  1. 새로운 테이블
    - `messages`
      - `id` (uuid, 기본 키)
      - `content` (text, 메시지 내용)
      - `user_id` (uuid, auth.users 참조)
      - `username` (text, 표시 이름)
      - `created_at` (timestamp with timezone)

  2. 보안
    - messages 테이블에 RLS 활성화
    - 정책:
      - 모든 사용자가 메시지를 읽을 수 있음
      - 인증된 사용자만 자신의 메시지를 작성할 수 있음
      - 사용자는 자신의 메시지만 수정/삭제할 수 있음
*/

CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content text NOT NULL,
  user_id uuid REFERENCES auth.users NOT NULL,
  username text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Row Level Security 활성화
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- 정책
CREATE POLICY "모든 사용자가 메시지를 읽을 수 있음"
  ON messages
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "인증된 사용자만 메시지를 작성할 수 있음"
  ON messages
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "사용자는 자신의 메시지만 수정할 수 있음"
  ON messages
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "사용자는 자신의 메시지만 삭제할 수 있음"
  ON messages
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- 빠른 쿼리를 위한 인덱스 생성
CREATE INDEX IF NOT EXISTS messages_created_at_idx ON messages (created_at);