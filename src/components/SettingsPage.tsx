
import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Separator } from "@/components/ui/separator";
import { Settings, Users, Bell, Info } from "lucide-react";

const SettingsPage = () => {
  const [profile, setProfile] = useState({
    name: "投資新手小王",
    userId: "investor2024",
    email: "wang@example.com"
  });
  
  const [notifications, setNotifications] = useState({
    investment: true,
    chat: true,
    ranking: false
  });

  const [darkMode, setDarkMode] = useState(false);

  // Mock QR Code - in real app this would be generated
  const qrCodeData = `https://investverse.app/add-friend?id=${profile.userId}`;

  const friends = [
    { name: "投資大師Tom", id: "master_tom", status: "在線" },
    { name: "環保投資者Lisa", id: "green_lisa", status: "離線" },
    { name: "交易員Kevin", id: "trader_kevin", status: "在線" }
  ];

  return (
    <div className="flex flex-col h-full bg-gray-50">
      {/* Header */}
      <div className="flex items-center justify-between p-4 bg-white border-b border-gray-200">
        <h1 className="text-xl font-bold">設定</h1>
        <Settings size={24} className="text-gray-600" />
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-6">
        {/* Profile Section */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">個人資料</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center gap-4">
              <Avatar className="w-20 h-20">
                <AvatarImage src="/placeholder-avatar.jpg" />
                <AvatarFallback className="bg-line-green text-white text-xl">
                  {profile.name.charAt(0)}
                </AvatarFallback>
              </Avatar>
              <Button variant="outline" size="sm">
                更換頭像
              </Button>
            </div>
            
            <div className="space-y-3">
              <div>
                <label className="text-sm font-medium text-gray-700">暱稱</label>
                <Input
                  value={profile.name}
                  onChange={(e) => setProfile({...profile, name: e.target.value})}
                  className="mt-1"
                />
              </div>
              
              <div>
                <label className="text-sm font-medium text-gray-700">用戶 ID</label>
                <Input
                  value={profile.userId}
                  onChange={(e) => setProfile({...profile, userId: e.target.value})}
                  className="mt-1"
                />
              </div>
              
              <div>
                <label className="text-sm font-medium text-gray-700">電子郵件</label>
                <Input
                  value={profile.email}
                  onChange={(e) => setProfile({...profile, email: e.target.value})}
                  className="mt-1"
                  type="email"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* QR Code Section */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">我的 QR Code</CardTitle>
          </CardHeader>
          <CardContent className="text-center">
            <div className="w-48 h-48 mx-auto bg-white border-2 border-gray-200 rounded-lg flex items-center justify-center mb-4">
              <div className="text-center">
                <div className="w-32 h-32 bg-gray-200 rounded mb-2 mx-auto flex items-center justify-center">
                  <span className="text-xs text-gray-500">QR Code</span>
                </div>
                <p className="text-xs text-gray-600">掃描加好友</p>
              </div>
            </div>
            <div className="flex gap-2">
              <Button variant="outline" className="flex-1">
                保存圖片
              </Button>
              <Button variant="outline" className="flex-1">
                分享
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Friends Management */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <Users size={20} />
              好友管理
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex gap-2 mb-4">
              <Input placeholder="輸入用戶 ID 或掃描 QR Code" className="flex-1" />
              <Button className="bg-line-green hover:bg-line-dark">
                添加
              </Button>
            </div>
            
            <div className="space-y-3">
              <h4 className="font-medium text-sm">好友列表 ({friends.length})</h4>
              {friends.map((friend) => (
                <div key={friend.id} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <Avatar className="w-10 h-10">
                      <AvatarFallback className="bg-gray-300">
                        {friend.name.charAt(0)}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <p className="font-medium text-sm">{friend.name}</p>
                      <p className="text-xs text-gray-500">@{friend.id}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className={`w-2 h-2 rounded-full ${
                      friend.status === "在線" ? "bg-green-500" : "bg-gray-400"
                    }`} />
                    <span className="text-xs text-gray-500">{friend.status}</span>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Notification Settings */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <Bell size={20} />
              通知設定
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">投資提醒</p>
                <p className="text-sm text-gray-600">排名變化、重要市場動態</p>
              </div>
              <Switch
                checked={notifications.investment}
                onCheckedChange={(checked) => 
                  setNotifications({...notifications, investment: checked})}
              />
            </div>
            
            <Separator />
            
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">聊天訊息</p>
                <p className="text-sm text-gray-600">群組和私人訊息通知</p>
              </div>
              <Switch
                checked={notifications.chat}
                onCheckedChange={(checked) => 
                  setNotifications({...notifications, chat: checked})}
              />
            </div>
            
            <Separator />
            
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">排行榜更新</p>
                <p className="text-sm text-gray-600">每週排名結果通知</p>
              </div>
              <Switch
                checked={notifications.ranking}
                onCheckedChange={(checked) => 
                  setNotifications({...notifications, ranking: checked})}
              />
            </div>
          </CardContent>
        </Card>

        {/* App Settings */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">應用設定</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="font-medium">深色模式</p>
                <p className="text-sm text-gray-600">切換至深色主題</p>
              </div>
              <Switch
                checked={darkMode}
                onCheckedChange={setDarkMode}
              />
            </div>
            
            <Separator />
            
            <div className="flex items-center justify-between">
              <p className="font-medium">語言</p>
              <Button variant="outline" size="sm">
                繁體中文
              </Button>
            </div>
            
            <Separator />
            
            <div className="flex items-center justify-between">
              <p className="font-medium">KYC 身份驗證</p>
              <Button variant="outline" size="sm" className="text-orange-600 border-orange-300">
                立即驗證
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* About Section */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg flex items-center gap-2">
              <Info size={20} />
              關於
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex justify-between">
              <span className="text-gray-600">版本</span>
              <span>1.0.0</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">客服支援</span>
              <Button variant="link" size="sm" className="p-0 h-auto">
                聯繫我們
              </Button>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">隱私政策</span>
              <Button variant="link" size="sm" className="p-0 h-auto">
                查看
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default SettingsPage;
