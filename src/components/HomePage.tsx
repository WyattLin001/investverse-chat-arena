
import { useState } from "react";
import { Search, Bell } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import RankingCarousel from "@/components/RankingCarousel";
import GroupCard from "@/components/GroupCard";

const HomePage = () => {
  const [selectedCategory, setSelectedCategory] = useState("全部");
  const [ntwBalance] = useState(5000);

  const categories = ["全部", "科技股", "綠能", "短期投機", "價值投資"];
  
  const mockGroups = [
    {
      id: 1,
      name: "科技股挑戰賽",
      host: "投資大師Tom",
      returnRate: 18.5,
      entryFee: "2 花束 (200 NTD)",
      members: 156,
      category: "科技股"
    },
    {
      id: 2,
      name: "綠能未來",
      host: "環保投資者Lisa",
      returnRate: 12.3,
      entryFee: "1 火箭 (1000 NTD)",
      members: 89,
      category: "綠能"
    },
    {
      id: 3,
      name: "短線交易王",
      host: "快手Kevin",
      returnRate: 25.7,
      entryFee: "5 花束 (500 NTD)",
      members: 234,
      category: "短期投機"
    }
  ];

  const filteredGroups = selectedCategory === "全部" 
    ? mockGroups 
    : mockGroups.filter(group => group.category === selectedCategory);

  return (
    <div className="flex flex-col h-full bg-gray-50">
      {/* Top Navigation */}
      <div className="flex items-center justify-between p-4 bg-white border-b border-gray-200">
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium text-gray-600">NTD</span>
          <span className="text-lg font-bold text-line-green">{ntwBalance.toLocaleString()}</span>
        </div>
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="sm">
            <Bell size={20} />
          </Button>
          <Button variant="ghost" size="sm">
            <Search size={20} />
          </Button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        {/* Ranking Carousel */}
        <div className="p-4">
          <RankingCarousel />
        </div>

        {/* Category Tabs */}
        <div className="px-4 pb-4">
          <div className="flex gap-2 overflow-x-auto scrollbar-hide">
            {categories.map((category) => (
              <Button
                key={category}
                variant={selectedCategory === category ? "default" : "outline"}
                size="sm"
                className={`whitespace-nowrap ${
                  selectedCategory === category
                    ? "bg-line-green hover:bg-line-dark"
                    : "border-gray-300 text-gray-600 hover:bg-gray-100"
                }`}
                onClick={() => setSelectedCategory(category)}
              >
                {category}
              </Button>
            ))}
          </div>
        </div>

        {/* Groups List */}
        <div className="px-4 space-y-3">
          <h2 className="text-lg font-bold text-gray-800">推薦群組</h2>
          {filteredGroups.map((group) => (
            <GroupCard key={group.id} group={group} />
          ))}
        </div>

        {/* Leaderboard Section */}
        <div className="p-4 mt-6">
          <Card>
            <CardContent className="p-4">
              <h3 className="text-lg font-bold mb-4">本週排行榜</h3>
              <div className="space-y-3">
                {[
                  { rank: 1, name: "投資大師Tom", return: 18.5, badge: "🥇" },
                  { rank: 2, name: "環保投資者Lisa", return: 12.3, badge: "🥈" },
                  { rank: 3, name: "快手Kevin", return: 25.7, badge: "🥉" },
                ].map((item) => (
                  <div key={item.rank} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <span className="text-lg">{item.badge}</span>
                      <span className="font-medium">{item.name}</span>
                    </div>
                    <Badge 
                      variant="secondary" 
                      className="bg-green-100 text-green-700 animate-number-roll"
                    >
                      +{item.return}%
                    </Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
