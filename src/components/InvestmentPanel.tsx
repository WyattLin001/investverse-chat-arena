
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

const InvestmentPanel = () => {
  const [selectedStock, setSelectedStock] = useState("");
  const [amount, setAmount] = useState("");
  const [action, setAction] = useState("buy");

  const mockPortfolio = [
    { symbol: "AAPL", name: "蘋果", shares: 100, value: 150000, return: 8.5 },
    { symbol: "TSLA", name: "特斯拉", shares: 50, value: 80000, return: -2.3 },
    { symbol: "NVDA", name: "輝達", shares: 30, value: 120000, return: 15.2 },
  ];

  const totalValue = mockPortfolio.reduce((sum, stock) => sum + stock.value, 0);
  const totalReturn = 12.8;

  return (
    <div className="p-4 space-y-4">
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">模擬投資面板</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Trading Controls */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
            <Select value={action} onValueChange={setAction}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="buy">買入</SelectItem>
                <SelectItem value="sell">賣出</SelectItem>
              </SelectContent>
            </Select>
            
            <Select value={selectedStock} onValueChange={setSelectedStock}>
              <SelectTrigger>
                <SelectValue placeholder="選擇股票" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="AAPL">AAPL - 蘋果</SelectItem>
                <SelectItem value="TSLA">TSLA - 特斯拉</SelectItem>
                <SelectItem value="NVDA">NVDA - 輝達</SelectItem>
                <SelectItem value="GOOGL">GOOGL - 谷歌</SelectItem>
              </SelectContent>
            </Select>
            
            <Input
              placeholder="金額 (NTD)"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              type="number"
            />
            
            <Button className="bg-line-green hover:bg-line-dark">
              執行交易
            </Button>
          </div>

          {/* Portfolio Overview */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="text-center">
              <p className="text-sm text-gray-600">總價值</p>
              <p className="text-xl font-bold">NT$ {totalValue.toLocaleString()}</p>
            </div>
            <div className="text-center">
              <p className="text-sm text-gray-600">總回報率</p>
              <Badge className="bg-green-100 text-green-700 text-lg font-bold">
                +{totalReturn}%
              </Badge>
            </div>
            <div className="text-center">
              <p className="text-sm text-gray-600">可用資金</p>
              <p className="text-xl font-bold">NT$ {(1000000 - totalValue).toLocaleString()}</p>
            </div>
          </div>

          {/* Holdings */}
          <div>
            <h4 className="font-medium mb-2">持倉明細</h4>
            <div className="space-y-2">
              {mockPortfolio.map((stock) => (
                <div key={stock.symbol} className="flex items-center justify-between p-2 bg-gray-50 rounded-lg">
                  <div>
                    <span className="font-medium">{stock.symbol}</span>
                    <span className="text-sm text-gray-600 ml-2">{stock.name}</span>
                  </div>
                  <div className="text-right">
                    <p className="text-sm">NT$ {stock.value.toLocaleString()}</p>
                    <Badge
                      variant="secondary"
                      className={
                        stock.return > 0
                          ? "bg-green-100 text-green-700"
                          : "bg-red-100 text-red-700"
                      }
                    >
                      {stock.return > 0 ? '+' : ''}{stock.return}%
                    </Badge>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default InvestmentPanel;
