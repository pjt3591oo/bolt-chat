/*
  # Chat Messages Schema

  1. New Tables
    - `messages`
      - `id` (uuid, primary key)
      - `content` (text)
      - `user_id` (uuid, references auth.users)
      - `username` (text)
      - `created_at` (timestamptz)

  2. Security
    - Enable RLS on messages table
    - Policies:
      - Anyone can read messages
      - Users can insert their own messages
      - Users can update their own messages
      - Users can delete their own messages

  3. Performance
    - Index on created_at for faster queries
*/

CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content text NOT NULL,
  user_id uuid REFERENCES auth.users NOT NULL,
  username text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policies with existence checks
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'Anyone can read messages'
  ) THEN
    CREATE POLICY "Anyone can read messages"
      ON messages
      FOR SELECT
      TO public
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'Users can insert their own messages'
  ) THEN
    CREATE POLICY "Users can insert their own messages"
      ON messages
      FOR INSERT
      TO authenticated
      WITH CHECK (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'Users can update their own messages'
  ) THEN
    CREATE POLICY "Users can update their own messages"
      ON messages
      FOR UPDATE
      TO authenticated
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'messages' AND policyname = 'Users can delete their own messages'
  ) THEN
    CREATE POLICY "Users can delete their own messages"
      ON messages
      FOR DELETE
      TO authenticated
      USING (auth.uid() = user_id);
  END IF;
END $$;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS messages_created_at_idx ON messages (created_at);