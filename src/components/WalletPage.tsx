
import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";

const WalletPage = () => {
  const [balance] = useState(5000);
  const [withdrawableAmount] = useState(2500); // For hosts

  const gifts = [
    {
      id: 1,
      name: "花束",
      price: 100,
      icon: "🌸",
      description: "表達支持的小禮物",
      color: "flower-pink"
    },
    {
      id: 2,
      name: "火箭",
      price: 1000,
      icon: "🚀",
      description: "推動投資組合起飛",
      color: "rocket-red"
    },
    {
      id: 3,
      name: "黃金",
      price: 5000,
      icon: "🏆",
      description: "最高等級的認可",
      color: "investment-gold"
    }
  ];

  const transactions = [
    {
      id: 1,
      type: "購買禮物",
      amount: -200,
      description: "花束 x2 → 科技股挑戰賽",
      status: "已確認",
      time: "2024-01-15 14:30",
      blockchainId: "0x1234...abcd"
    },
    {
      id: 2,
      type: "儲值",
      amount: 1000,
      description: "LINE Pay 儲值",
      status: "已確認",
      time: "2024-01-15 10:15",
      blockchainId: "0x5678...efgh"
    },
    {
      id: 3,
      type: "購買禮物",
      amount: -1000,
      description: "火箭 x1 → 綠能投資群",
      status: "處理中",
      time: "2024-01-14 16:45",
      blockchainId: "0x9abc...ijkl"
    }
  ];

  return (
    <div className="flex flex-col h-full bg-gray-50">
      {/* Header */}
      <div className="flex items-center justify-between p-4 bg-white border-b border-gray-200">
        <h1 className="text-xl font-bold">錢包</h1>
        <div className="text-right">
          <p className="text-sm text-gray-600">NTD 餘額</p>
          <p className="text-2xl font-bold text-line-green">
            {balance.toLocaleString()}
          </p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-6">
        {/* Top Up Section */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">儲值</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 gap-3">
              <Button className="bg-green-600 hover:bg-green-700 h-12">
                LINE Pay 儲值
              </Button>
              <Button variant="outline" className="h-12">
                街口支付
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Gift Shop */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">禮物商店</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 gap-4">
              {gifts.map((gift) => (
                <div
                  key={gift.id}
                  className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:shadow-sm transition-shadow"
                >
                  <div className="flex items-center gap-4">
                    <div className="text-3xl">{gift.icon}</div>
                    <div>
                      <h4 className="font-bold">{gift.name}</h4>
                      <p className="text-sm text-gray-600">{gift.description}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-bold text-lg">NT$ {gift.price}</p>
                    <Button
                      className="bg-line-green hover:bg-line-dark mt-2 animate-gift-fly"
                      size="sm"
                    >
                      購買
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Host Withdrawal (Conditional) */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">主持人提領</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between mb-4">
              <div>
                <p className="text-sm text-gray-600">可提領金額</p>
                <p className="text-xl font-bold text-green-600">
                  NT$ {withdrawableAmount.toLocaleString()}
                </p>
                <p className="text-xs text-gray-500">
                  (已扣除 5% 平台手續費)
                </p>
              </div>
              <Button className="bg-orange-500 hover:bg-orange-600">
                申請提領
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Transaction History */}
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">交易記錄</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {transactions.map((tx) => (
                <div key={tx.id}>
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-medium text-sm">{tx.type}</span>
                        <Badge
                          variant={tx.status === "已確認" ? "default" : "secondary"}
                          className={
                            tx.status === "已確認"
                              ? "bg-green-100 text-green-700"
                              : "bg-yellow-100 text-yellow-700"
                          }
                        >
                          {tx.status}
                        </Badge>
                      </div>
                      <p className="text-xs text-gray-600 mb-1">{tx.description}</p>
                      <div className="flex items-center gap-2">
                        <span className="text-xs text-gray-500">{tx.time}</span>
                        <Button
                          variant="link"
                          size="sm"
                          className="text-xs p-0 h-auto text-blue-600"
                        >
                          區塊鏈記錄
                        </Button>
                      </div>
                    </div>
                    <div className="text-right">
                      <span
                        className={`font-bold ${
                          tx.amount > 0 ? "text-green-600" : "text-red-600"
                        }`}
                      >
                        {tx.amount > 0 ? "+" : ""}NT$ {Math.abs(tx.amount).toLocaleString()}
                      </span>
                    </div>
                  </div>
                  {tx.id !== transactions[transactions.length - 1].id && (
                    <Separator className="my-4" />
                  )}
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default WalletPage;
