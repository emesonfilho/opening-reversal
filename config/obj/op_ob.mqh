enum OPERATION_TYPE{
    BUY = 0,
    SELL = 1
};

class OpeObj{
    public:
        OPERATION_TYPE type;
        bool parcial_state;
        double price_entry;
        double sl_price;
        double tk_price;
        ulong ticket;
        bool is_real;
        string date;
        bool state;
        
    public:
        OpeObj(void){
            this.is_real = false;
        }
        
        OpeObj(OPERATION_TYPE otype, double oprice_entry, string odate, double osl_price, double otk_price, ulong oticket){
            this.price_entry = oprice_entry;
            this.parcial_state = false;
            this.sl_price = osl_price;
            this.tk_price = otk_price;
            this.ticket = oticket;
            this.is_real = true;
            this.date = odate;
            this.state = true;
            this.type = otype;
        }
        
        bool InTrade(double current_price){
            if(current_price > this.sl_price && current_price < this.tk_price){
                return true;
                
            }
            
            return false;
        }   
};