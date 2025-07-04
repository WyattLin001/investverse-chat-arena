
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Users } from "lucide-react";

interface Group {
  id: number;
  name: string;
  host: string;
  returnRate: number;
  entryFee: string;
  members: number;
  category: string;
}

interface GroupCardProps {
  group: Group;
}

const GroupCard = ({ group }: GroupCardProps) => {
  return (
    <Card className="hover:shadow-md transition-shadow duration-200">
      <CardContent className="p-4">
        <div className="flex items-center justify-between">
          <div className="flex-1">
            <h3 className="font-bold text-base mb-1">{group.name}</h3>
            <p className="text-sm text-gray-600 mb-2">主持人：{group.host}</p>
            <div className="flex items-center gap-4">
              <Badge 
                variant="secondary" 
                className={`${
                  group.returnRate > 0 
                    ? "bg-green-100 text-green-700" 
                    : "bg-red-100 text-red-700"
                }`}
              >
                {group.returnRate > 0 ? '+' : ''}{group.returnRate}%
              </Badge>
              <span className="text-sm text-gray-500">{group.entryFee}</span>
              <div className="flex items-center gap-1 text-sm text-gray-500">
                <Users size={14} />
                <span>{group.members}</span>
              </div>
            </div>
          </div>
          <Button 
            className="bg-orange-500 hover:bg-orange-600 text-white font-medium"
            size="sm"
          >
            加入群組
          </Button>
        </div>
      </CardContent>
    </Card>
  );
};

export default GroupCard;
