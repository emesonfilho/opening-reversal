#include <Controls\Dialog.mqh>
#include <Controls\Label.mqh>
#include <Trade\Trade.mqh>

#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width) 
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width) 
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width) 
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width) 
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate 
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate 

CAppDialog window;
CLabel label;
CTrade trade;

class Useful{
    public:
        static double GetCurrentPrice(){
            MqlRates velas[];
            CopyRates(_Symbol, _Period, 0, 1, velas);
            ArraySetAsSeries(velas, true);
            return velas[0].close;
        } 
    
        static double GetClosePrice(int day = 1){
            MqlRates rate[];
            CopyRates(Symbol(), PERIOD_D1, day, 1, rate);
            
            return rate[0].close;
        }
    
        static string GetCurrentDate(){
            return TimeToString(TimeCurrent(), TIME_DATE);
        }
        
        static bool ClosePartial(string symbol, int type, double lots, int ticket, string comment = "1"){
              MqlTradeRequest request = {0};
              MqlTradeResult result = {0};
              request.action = TRADE_ACTION_DEAL;        
              request.position = ticket;          
              request.symbol = symbol;          
              request.volume = lots;                  
              request.deviation = 5;
              request.comment = comment;
              double price = 0;
              
              if(type == 0){
                 request.type = ORDER_TYPE_SELL;
                 request.price = SymbolInfoDouble(symbol,SYMBOL_BID);
                 
              }else if(type == 1){                  
                 request.type = ORDER_TYPE_BUY;
                 request.price = SymbolInfoDouble(symbol,SYMBOL_ASK);
                 
              }
                 
              if(!OrderSend(request, result)){
                 Print("OrderSend error " + DoubleToString(GetLastError()));
                 return false;
                 
              }else{
                 return true;
                 
              }
        }
        
        static bool PositionModify(ulong ticket, double sl, double tk){
            return trade.PositionModify(ticket, sl, tk);
        }
        
        static bool DoSell(double volume, string symbol, double entry_value, double sl, double tk, string comment = "0"){
            return trade.Sell(volume, symbol, entry_value, sl, tk, comment);
        }
        
        static bool DoBuy(double volume, string symbol, double entry_value, double sl, double tk, string comment = "0"){
            return trade.Buy(volume, symbol, entry_value, sl, tk, comment);
            
        }
        
        static ulong GetTicket(int i){
            return PositionGetTicket(i);
        }
        
        static ulong GetLastTicket(){
            return Useful::GetTicket(PositionsTotal()-1);
        }
        
        static void DeleteAllOrders(){
            for(int i = OrdersTotal() -1; i >= 0; i--){
                ulong ticket = OrderGetTicket(i);
                
                if(OrderSelect(ticket) && OrderGetString(ORDER_SYMBOL) == Symbol()){
                    trade.OrderDelete(ticket);
                    
                }
            }
        }
        
        static int allLoss(){
           
           return 1;
        }
        
        static void allTkSLPrice(){
            int i = 0;
           ulong ticket=0;
           int history_minutes = 10;
        
           Print("^^^ history ORDERS ^^^");
           HistorySelect(TimeCurrent()-(history_minutes * 60), TimeCurrent());
         
           for(i=0; i < HistoryOrdersTotal(); i++)
           {
              ticket=HistoryOrderGetTicket(i);
              Print(
                 "Order Ticket = " + ticket
                 + "; SL = " + HistoryOrderGetDouble(ticket,ORDER_SL)
                 + "; TP = " + HistoryOrderGetDouble(ticket,ORDER_TP)
              );
           }
           
           Print("^^^ history DEALS ^^^");
           for(i=0; i < HistoryDealsTotal(); i++)
           {
              ticket=HistoryDealGetTicket(i);
              
              long order=HistoryDealGetInteger(ticket, DEAL_ORDER);
              //order = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
              
              Print(
                 "Deal Ticket = " + ticket
                 + "; SL = " + HistoryOrderGetDouble(order,ORDER_SL)
                 + "; TP = " + HistoryOrderGetDouble(order,ORDER_TP)
              );
           }
        }
        
        static int getDay(){
            MqlDateTime str1;
            TimeToStruct(TimeCurrent(), str1);
            
            return str1.day_of_week;
        }
        
        static bool isNewDay(int day){
            if(day != Useful::getDay()){
                return true;
                
            }
            
            return false;
        }
        
        static bool displayWindow( string name = "Info", long chart_id = 0){
            if(!window.Create(chart_id, name, 0, 20, 20, 360, 324)) return false;
            window.Run();
            return true;
        }
        
        static bool putLabel(string text, string name = "1", int difY = 0, long chart_id = 0){
            int x1 = INDENT_RIGHT; 
            int y1 = INDENT_TOP + CONTROLS_GAP_Y + difY; 
            int x2 = x1 + 100; 
            int y2 = y1 + 20; 
            
            if(!label.Create(chart_id, name + "Label", 0, x1, y1, x2, y2)) return false;
            if(!label.Text(text)) return false;
            if(!window.Add(label)) return false;
            
            return true;
        }
        
        static void destroyWindow(int reason){
            window.Destroy(reason);
        }
        
        static bool postIt(string url, char &data[], char &result[]){
            string cookie = NULL, headers;
            int res = WebRequest("POST", url, "Content-Type: application/x-www-form-urlencoded", 500, data, result, headers);
            return res != -1;
        }
};