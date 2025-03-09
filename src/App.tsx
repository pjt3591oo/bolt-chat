import React, { useEffect, useState } from 'react';
import { supabase } from './lib/supabase';
import { AuthForm } from './components/AuthForm';
import { ChatMessage } from './components/ChatMessage';
import { ChatInput } from './components/ChatInput';
import { MessageSquare, LogOut } from 'lucide-react';

interface Message {
  id: string;
  content: string;
  username: string;
  created_at: string;
  user_id: string;
}

function App() {
  const [session, setSession] = useState(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [username, setUsername] = useState('');

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session?.user?.email) {
        setUsername(session.user.email.split('@')[0]);
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session?.user?.email) {
        setUsername(session.user.email.split('@')[0]);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  useEffect(() => {
    const fetchMessages = async () => {
      const { data, error } = await supabase
        .from('messages')
        .select('*')
        .order('created_at', { ascending: true });

      if (error) {
        console.error('메시지 불러오기 오류:', error);
      } else {
        setMessages(data || []);
      }
    };

    fetchMessages();

    const subscription = supabase
      .channel('messages')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'messages' }, 
        (payload) => {
          setMessages(current => [...current, payload.new as Message]);
        }
      )
      .subscribe();

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const handleSendMessage = async (content: string) => {
    if (!session?.user) return;

    const { error } = await supabase
      .from('messages')
      .insert([
        {
          content,
          user_id: session.user.id,
          username: username,
        },
      ]);

    if (error) {
      console.error('메시지 전송 오류:', error);
    }
  };

  const handleLogout = async () => {
    await supabase.auth.signOut();
  };

  if (!session) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <AuthForm />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto bg-white shadow-lg min-h-screen flex flex-col">
        <div className="bg-indigo-600 text-white p-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <MessageSquare className="w-6 h-6" />
            <h1 className="text-xl font-bold">채팅방</h1>
          </div>
          <div className="flex items-center gap-4">
            <span className="text-sm">{username}님 환영합니다</span>
            <button
              onClick={handleLogout}
              className="flex items-center gap-2 px-3 py-1 bg-indigo-700 rounded hover:bg-indigo-800 transition-colors"
            >
              <LogOut className="w-4 h-4" />
              로그아웃
            </button>
          </div>
        </div>

        <div className="flex-1 p-4 overflow-y-auto">
          {messages.map((message) => (
            <ChatMessage
              key={message.id}
              message={message}
              isCurrentUser={message.user_id === session.user.id}
            />
          ))}
        </div>

        <ChatInput onSendMessage={handleSendMessage} />
      </div>
    </div>
  );
}

export default App;