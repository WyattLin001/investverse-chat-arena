
import { useState } from "react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import HomePage from "@/components/HomePage";
import ChatPage from "@/components/ChatPage";
import InfoPage from "@/components/InfoPage";
import WalletPage from "@/components/WalletPage";
import SettingsPage from "@/components/SettingsPage";
import BottomNavigation from "@/components/BottomNavigation";
import { Home, Chat, Wallet, Settings, Info } from "lucide-react";

const Index = () => {
  const [activeTab, setActiveTab] = useState("home");

  return (
    <div className="min-h-screen bg-background font-noto">
      <Tabs value={activeTab} onValueChange={setActiveTab} className="h-screen flex flex-col">
        <div className="flex-1 overflow-hidden">
          <TabsContent value="home" className="h-full m-0">
            <HomePage />
          </TabsContent>
          <TabsContent value="chat" className="h-full m-0">
            <ChatPage />
          </TabsContent>
          <TabsContent value="info" className="h-full m-0">
            <InfoPage />
          </TabsContent>
          <TabsContent value="wallet" className="h-full m-0">
            <WalletPage />
          </TabsContent>
          <TabsContent value="settings" className="h-full m-0">
            <SettingsPage />
          </TabsContent>
        </div>
        
        <BottomNavigation activeTab={activeTab} onTabChange={setActiveTab} />
      </Tabs>
    </div>
  );
};

export default Index;
