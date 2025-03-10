/*
  # Create messages table for chat service

  1. New Tables
    - `messages`
      - `id` (uuid, primary key)
      - `content` (text, message content)
      - `user_id` (uuid, foreign key to auth.users)
      - `username` (text, display name)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `messages` table
    - Add policies for:
      - Anyone can read messages
      - Authenticated users can insert their own messages
*/

CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content text NOT NULL,
  user_id uuid REFERENCES auth.users(id) NOT NULL,
  username text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read messages"
  ON messages
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Users can insert their own messages"
  ON messages
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);