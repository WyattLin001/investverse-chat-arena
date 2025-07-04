
import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Users, Gift, Wallet, Info } from "lucide-react";
import InvestmentPanel from "@/components/InvestmentPanel";

const ChatPage = () => {
  const [message, setMessage] = useState("");
  const [showInvestmentPanel, setShowInvestmentPanel] = useState(false);

  const mockMessages = [
    {
      id: 1,
      user: "投資大師Tom",
      message: "大家好！今天我們來討論一下科技股的趨勢",
      time: "14:30",
      isHost: true,
      isOwn: false
    },
    {
      id: 2,
      user: "你",
      message: "AAPL 最近表現不錯，有什麼看法嗎？",
      time: "14:32",
      isHost: false,
      isOwn: true
    },
    {
      id: 3,
      user: "投資大師Tom",
      message: "[買入] AAPL 10萬",
      time: "14:35",
      isHost: true,
      isOwn: false,
      isInvestmentCommand: true
    },
    {
      id: 4,
      user: "Lisa",
      message: "好決定！我也看好蘋果",
      time: "14:36",
      isHost: false,
      isOwn: false
    }
  ];

  return (
    <div className="flex h-full bg-gray-50">
      {/* Chat List - Hidden on mobile, shown on larger screens */}
      <div className="hidden md:block w-80 bg-white border-r border-gray-200">
        <div className="p-4 border-b">
          <h2 className="font-bold text-lg">聊天</h2>
        </div>
        <div className="overflow-y-auto">
          {[
            { name: "科技股挑戰賽", lastMessage: "[買入] AAPL 10萬", time: "14:35", active: true },
            { name: "綠能投資討論", lastMessage: "今天綠能股表現如何？", time: "13:20", active: false },
            { name: "短線交易群", lastMessage: "快進快出，注意風險", time: "12:45", active: false },
          ].map((chat, index) => (
            <div
              key={index}
              className={`p-4 border-b cursor-pointer hover:bg-gray-50 ${
                chat.active ? "bg-line-light border-l-4 border-line-green" : ""
              }`}
            >
              <div className="flex justify-between items-start mb-1">
                <h3 className="font-medium text-sm">{chat.name}</h3>
                <span className="text-xs text-gray-500">{chat.time}</span>
              </div>
              <p className="text-xs text-gray-600 truncate">{chat.lastMessage}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Main Chat Area */}
      <div className="flex-1 flex flex-col">
        {/* Chat Header */}
        <div className="flex items-center justify-between p-4 bg-white border-b border-gray-200">
          <div>
            <h1 className="font-bold text-lg">科技股挑戰賽</h1>
            <div className="flex items-center gap-2 text-sm text-gray-600">
              <span>主持人：投資大師Tom</span>
              <div className="flex items-center gap-1">
                <Users size={14} />
                <span>156人</span>
              </div>
            </div>
          </div>
          <div className="flex gap-2">
            <Button variant="outline" size="sm">
              <Gift size={16} />
            </Button>
            <Button 
              variant="outline" 
              size="sm"
              onClick={() => setShowInvestmentPanel(!showInvestmentPanel)}
            >
              <Wallet size={16} />
            </Button>
            <Button variant="outline" size="sm">
              <Info size={16} />
            </Button>
          </div>
        </div>

        {/* Messages Area */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          {mockMessages.map((msg) => (
            <div
              key={msg.id}
              className={`flex ${msg.isOwn ? "justify-end" : "justify-start"}`}
            >
              <div className={`max-w-xs lg:max-w-md ${msg.isOwn ? "order-2" : "order-1"}`}>
                {!msg.isOwn && (
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-xs font-medium text-gray-700">
                      {msg.user}
                    </span>
                    {msg.isHost && (
                      <Badge className="bg-line-green text-white text-xs">主持人</Badge>
                    )}
                  </div>
                )}
                <div
                  className={`rounded-lg p-3 chat-bubble ${
                    msg.isInvestmentCommand
                      ? "investment-command"
                      : msg.isOwn
                      ? "bg-line-green text-white"
                      : "bg-white border border-gray-200"
                  }`}
                >
                  <p className="text-sm">{msg.message}</p>
                </div>
                <span className="text-xs text-gray-500 mt-1 block">
                  {msg.time}
                </span>
              </div>
            </div>
          ))}
        </div>

        {/* Investment Panel */}
        {showInvestmentPanel && (
          <div className="border-t border-gray-200 bg-white">
            <InvestmentPanel />
          </div>
        )}

        {/* Message Input */}
        <div className="p-4 bg-white border-t border-gray-200">
          <div className="flex gap-2">
            <Input
              placeholder="輸入訊息..."
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              className="flex-1"
            />
            <Button className="bg-line-green hover:bg-line-dark">
              發送
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ChatPage;
