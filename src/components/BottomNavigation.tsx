
import { Home, Chat, Info, Wallet, Settings } from "lucide-react";
import { TabsList, TabsTrigger } from "@/components/ui/tabs";

interface BottomNavigationProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

const BottomNavigation = ({ activeTab, onTabChange }: BottomNavigationProps) => {
  const navItems = [
    { id: "home", icon: Home, label: "主頁" },
    { id: "chat", icon: Chat, label: "聊天" },
    { id: "info", icon: Info, label: "資訊" },
    { id: "wallet", icon: Wallet, label: "錢包" },
    { id: "settings", icon: Settings, label: "設定" },
  ];

  return (
    <TabsList className="h-16 w-full bg-white border-t border-gray-200 rounded-none p-0 ios-safe-area">
      {navItems.map((item) => (
        <TabsTrigger
          key={item.id}
          value={item.id}
          className={`flex-1 flex flex-col items-center justify-center gap-1 h-full text-xs font-medium transition-colors duration-200 ${
            activeTab === item.id 
              ? "text-line-green bg-line-light/30" 
              : "text-gray-500 hover:text-gray-700"
          }`}
          onClick={() => onTabChange(item.id)}
        >
          <item.icon size={20} />
          <span>{item.label}</span>
        </TabsTrigger>
      ))}
    </TabsList>
  );
};

export default BottomNavigation;
