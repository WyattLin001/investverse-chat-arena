
import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";

const RankingCarousel = () => {
  const [activeTab, setActiveTab] = useState("週");

  const rankings = {
    週: [
      { name: "投資大師Tom", return: 18.5, badge: "🥇", color: "investment-gold" },
      { name: "環保投資者Lisa", return: 12.3, badge: "🥈", color: "investment-silver" },
      { name: "快手Kevin", return: 25.7, badge: "🥉", color: "investment-bronze" },
    ],
    季: [
      { name: "價值投資王Sarah", return: 45.2, badge: "🥇", color: "investment-gold" },
      { name: "科技股專家Mike", return: 38.9, badge: "🥈", color: "investment-silver" },
      { name: "穩健操盤手Amy", return: 32.1, badge: "🥉", color: "investment-bronze" },
    ],
    年: [
      { name: "股神級玩家David", return: 125.8, badge: "🥇", color: "investment-gold" },
      { name: "長期投資達人Jenny", return: 98.7, badge: "🥈", color: "investment-silver" },
      { name: "全能交易員Chris", return: 87.4, badge: "🥉", color: "investment-bronze" },
    ]
  };

  const tabs = ["週", "季", "年"];

  return (
    <div className="w-full">
      <div className="flex items-center justify-between mb-3">
        <h2 className="text-lg font-bold text-gray-800">排行榜</h2>
        <div className="flex gap-1 bg-gray-100 rounded-full p-1">
          {tabs.map((tab) => (
            <Button
              key={tab}
              variant="ghost"
              size="sm"
              className={`px-3 py-1 text-xs rounded-full ${
                activeTab === tab
                  ? "bg-line-green text-white"
                  : "text-gray-600 hover:bg-gray-200"
              }`}
              onClick={() => setActiveTab(tab)}
            >
              本{tab}冠軍
            </Button>
          ))}
        </div>
      </div>
      
      <div className="flex gap-3 overflow-x-auto scrollbar-hide pb-2">
        {rankings[activeTab as keyof typeof rankings].map((user, index) => (
          <Card 
            key={index} 
            className="min-w-[200px] bg-gradient-to-br from-white to-gray-50 border-2 hover:shadow-lg transition-all duration-300"
            style={{
              borderColor: index === 0 ? '#FFD700' : index === 1 ? '#C0C0C0' : '#CD7F32'
            }}
          >
            <CardContent className="p-4 text-center">
              <div className="text-3xl mb-2">{user.badge}</div>
              <h3 className="font-bold text-sm mb-1">{user.name}</h3>
              <Badge 
                className="bg-green-100 text-green-700 font-bold animate-number-roll"
                variant="secondary"
              >
                +{user.return}%
              </Badge>
              <div className="text-xs text-gray-500 mt-1">
                本{activeTab}冠軍
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default RankingCarousel;
