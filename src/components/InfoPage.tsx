
import { useState } from "react";
import { Search, Heart, Chat, Home } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";

const InfoPage = () => {
  const [searchQuery, setSearchQuery] = useState("");

  const mockArticles = [
    {
      id: 1,
      title: "AI 股票投資策略：如何在科技革命中獲利",
      author: "投資分析師王小明",
      summary: "探討人工智慧對股市的影響，以及如何選擇相關投資標的...",
      likes: 245,
      comments: 67,
      readTime: "5 min",
      category: "科技股",
      isSubscribed: false
    },
    {
      id: 2,
      title: "綠能轉型：太陽能股票投資機會分析",
      author: "環保投資專家Lisa",
      summary: "全球綠能政策推動下，太陽能產業迎來黃金發展期...",
      likes: 189,
      comments: 43,
      readTime: "7 min",
      category: "綠能",
      isSubscribed: true
    },
    {
      id: 3,
      title: "短線交易心法：如何在波動市場中生存",
      author: "交易員Kevin",
      summary: "分享短線交易的技巧與風險控制策略，適合積極投資者...",
      likes: 356,
      comments: 89,
      readTime: "4 min",
      category: "短期投機",
      isSubscribed: false
    }
  ];

  const filteredArticles = mockArticles.filter(article =>
    article.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    article.author.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="flex flex-col h-full bg-gray-50">
      {/* Header */}
      <div className="flex items-center justify-between p-4 bg-white border-b border-gray-200">
        <h1 className="text-xl font-bold">投資資訊</h1>
        <Button variant="ghost" size="sm">
          <Search size={20} />
        </Button>
      </div>

      {/* Search Bar */}
      <div className="p-4 bg-white border-b border-gray-200">
        <Input
          placeholder="搜尋文章或作者..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full"
        />
      </div>

      {/* Articles List */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {filteredArticles.map((article) => (
          <Card key={article.id} className="hover:shadow-md transition-shadow duration-200">
            <CardContent className="p-4">
              <div className="flex justify-between items-start mb-2">
                <Badge variant="outline" className="text-xs">
                  {article.category}
                </Badge>
                <span className="text-xs text-gray-500">{article.readTime}</span>
              </div>
              
              <h3 className="font-bold text-base mb-2 line-clamp-2">
                {article.title}
              </h3>
              
              <p className="text-sm text-gray-600 mb-3 line-clamp-2">
                {article.summary}
              </p>
              
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                    <Home size={14} />
                  </div>
                  <div>
                    <p className="text-sm font-medium">{article.author}</p>
                    <Button
                      variant={article.isSubscribed ? "default" : "outline"}
                      size="sm"
                      className={`text-xs h-6 ${
                        article.isSubscribed
                          ? "bg-line-green hover:bg-line-dark"
                          : ""
                      }`}
                    >
                      {article.isSubscribed ? "已訂閱" : "訂閱"}
                    </Button>
                  </div>
                </div>
                
                <div className="flex items-center gap-4">
                  <div className="flex items-center gap-1">
                    <Heart size={16} className="text-red-500" />
                    <span className="text-sm">{article.likes}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Chat size={16} className="text-gray-500" />
                    <span className="text-sm">{article.comments}</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Recommended Authors */}
      <div className="p-4 bg-white border-t border-gray-200">
        <h3 className="font-bold mb-3">推薦作者</h3>
        <div className="flex gap-3 overflow-x-auto scrollbar-hide">
          {["投資大師Tom", "環保專家Lisa", "交易員Kevin"].map((author) => (
            <div key={author} className="flex-shrink-0 text-center">
              <div className="w-12 h-12 bg-gray-300 rounded-full flex items-center justify-center mb-2">
                <Home size={20} />
              </div>
              <p className="text-xs font-medium">{author}</p>
              <Button variant="outline" size="sm" className="text-xs mt-1 h-6">
                關注
              </Button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default InfoPage;
