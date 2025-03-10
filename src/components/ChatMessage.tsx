import React from 'react';
import { formatDistanceToNow } from 'date-fns';
import { ko } from 'date-fns/locale';
import { User } from 'lucide-react';

interface Message {
  id: string;
  content: string;
  username: string;
  created_at: string;
  user_id: string;
}

interface ChatMessageProps {
  message: Message;
  isCurrentUser: boolean;
}

export function ChatMessage({ message, isCurrentUser }: ChatMessageProps) {
  return (
    <div className={`flex ${isCurrentUser ? 'justify-end' : 'justify-start'} mb-4`}>
      <div className={`flex ${isCurrentUser ? 'flex-row-reverse' : 'flex-row'} items-start max-w-[80%]`}>
        <div className="flex-shrink-0">
          <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center">
            <User className="w-5 h-5 text-gray-500" />
          </div>
        </div>
        <div className={`mx-2 ${isCurrentUser ? 'items-end' : 'items-start'}`}>
          <div className="flex items-center mb-1">
            <span className="text-sm font-medium text-gray-900">{message.username}</span>
            <span className="ml-2 text-xs text-gray-500">
              {formatDistanceToNow(new Date(message.created_at), { addSuffix: true, locale: ko })}
            </span>
          </div>
          <div className={`rounded-lg px-4 py-2 ${
            isCurrentUser ? 'bg-indigo-600 text-white' : 'bg-gray-100 text-gray-900'
          }`}>
            {message.content}
          </div>
        </div>
      </div>
    </div>
  );
}