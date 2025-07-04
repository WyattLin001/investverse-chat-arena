
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

const RankingCarousel = () => {
  const topRanked = [
    { name: "投資大師Tom", return: 18.5, badge: "🥇", color: "investment-gold" },
    { name: "環保投資者Lisa", return: 12.3, badge: "🥈", color: "investment-silver" },
    { name: "快手Kevin", return: 25.7, badge: "🥉", color: "investment-bronze" },
  ];

  return (
    <div className="w-full">
      <h2 className="text-lg font-bold mb-3 text-gray-800">本週冠軍</h2>
      <div className="flex gap-3 overflow-x-auto scrollbar-hide pb-2">
        {topRanked.map((user, index) => (
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
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default RankingCarousel;
