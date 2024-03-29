//+------------------------------------------------------------------+
//|                                              EdelweissExpert.mq4 |
//|                                  Copyright 2024, Andrea Terlizzi |
//|                                            https://www.unisa.it/ |
//+------------------------------------------------------------------+
#property copyright "2024, Andrea Terlizzi"
#property link      "https://www.unisa.it/"
#property version   "1.00"
#property description "Edelweiss Expert Advisor"

//--- library
#include <MovingAverages.mqh>

//--- constants
#define MAGICMA 224785

// Operation parameters
input bool optimize_lot = true;
input double lot = 0.1; // lots to Trade
input double lot_decrease_factor = 3.0;
input int price_slippage = 3;
input double max_risk = 0.01;  // max balance risk
input int default_trailing_stop = 30;  // to compute default stop-loss
input int default_take_profit = 50;  // default take profit

// Opening/closing parameters
input int buy_signals_t = 1;
input int sell_signals_t = 1;
// input int close_signals_t = 1;

// MA parameters
input bool use_ma_signals = true;
input int ma_window_slow = 50;  // may also try 21
input int ma_window_fast = 20;  // may also try 7
input int ma_shift = 0;
input ENUM_MA_METHOD ma_method = MODE_EMA;
input ENUM_APPLIED_PRICE ma_price_type = PRICE_CLOSE;

// ATR parameters
input bool use_atr_sl_tp = true;
input double atr_stop_loss_factor = 2.0;
input double atr_take_profit_factor = 4.0;
input int atr_window = 14;
input double atr_normalized_volatility_t = 0.1;

// Stochastic oscillator parameters
input bool use_stochastic_signals = true;
input int stochastic_k_period = 14;
input int stochastic_d_period = 3;
input int stochastic_slowing = 3;
input ENUM_MA_METHOD stochastic_ma_method = MODE_SMA;
input int stochastic_price_field  = 0;  // type of price type used to compute stochastic oscillator 0=Low/High or 1=Close/Close
input double stochastic_over_bought_t = 80;  // stochastic overbought
input double stochastic_over_sold_t = 20;  // stochastic oversold
input bool stochastic_use_atr_volatility_signal = true;  // whether to use the ATR-based volatility signal in stochastic oscillator

// Awesome oscillator parameters
input bool use_awesome_signals = true;
input int awesome_saucers_bar_number = 3;  // number of consecutive bars to evaluate with the awesome oscillator saucers strategy
input bool awesome_check_stochastic = true;  // combine signals with oversold/overbought signals by stochastic oscillator

// ADX parameters
input bool use_adx_signals = true;
input bool adx_use_parabolic_signal = true;
input int adx_period = 14;
input ENUM_APPLIED_PRICE adx_price_type = PRICE_CLOSE;
input double adx_min_market_trending_t = 20.0;
// input double adx_max_market_trending_t = 40.0;

// Parabolic SAR parameters
input double parabolic_step = 0.02;
input double parabolic_max_step = 0.2;

// Bollinger bands parameters
input bool use_bollinger_signals = true;
input int bollinger_period = 20;
input double bollinger_std_factor = 2.0;
input double bollinger_squeeze_t = 0.05;
input int bollinger_shift = 0;
input ENUM_APPLIED_PRICE bollinger_price_type = PRICE_CLOSE;
input bool use_adx_lateral_market_signal = true;

// MACD parameters
input bool use_macd_signals = false;
input bool use_macd_close = false;
input int macd_fast_ema_period = 12;
input int macd_slow_ema_period = 26;
input int macd_signal_period = 9;
input ENUM_APPLIED_PRICE macd_price_type = PRICE_CLOSE;
input double macd_open_level = 3.0;
input double macd_close_level = 2.0;
input int macd_ma_trend_period = 26;

// Visualization parameters
input bool verbose_log = false;


//--- Global Variables
datetime old_timestamp;  // to check if tick is old or new
double stop_level;  // market stop-level


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   Print("Initializing Edelweiss Expert Advisor...");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   int buy_signals = 0, sell_signals = 0, total;

   // Reset error
   ResetLastError();

   // Check for history and trading
   if(Bars < 100 || !IsTradeAllowed())
      return;
      
   // Trade only for first ticks of new bar
   if(Volume[0] > 1) 
      return;
      
   // Check if we already have open positions
   total = OrdersTotal();
   if (total > 0){
      return;
   }
   
   
   // Check if this is a new tick
   datetime time = iTime(_Symbol, _Period, 0);
   if (time == old_timestamp){
      Print("Old Tick: ",  string(time));
      return;
   }
   old_timestamp = time;
   
   // Get the current stop-level
   stop_level = MarketInfo(_Symbol, MODE_STOPLEVEL);
   
   
   // Check for buy signals
   buy_signals = CheckBuySignals();
   sell_signals = CheckSellSignals();
   
   if (buy_signals >= buy_signals_t) {
      if (AccountFreeMargin() < (1000 * lot)){
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return;
      }
      MakeOrder(ORDER_TYPE_BUY);
   }
   
   // Check for sell signals
   else if (sell_signals >= sell_signals_t) {
      if (AccountFreeMargin() < (1000 * lot)){
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return;
      }
      MakeOrder(ORDER_TYPE_SELL);
   }
   
   // TODO: maybe check for additional close position conditions (e.g. EMA-based or Stochastic oscillator-based)
   
   return;
 }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   Print("De-Initializing Edelweiss Expert Advisor, code: ", string(reason));
}


//+------------------------------------------------------------------+
//| Buy signal check function                                        |
//+------------------------------------------------------------------+
int CheckBuySignals(){
   int buy_signals = 0;
   
   // Check for MA signal
   if (use_ma_signals && MABuySignal(_Symbol, 
                                     (ENUM_TIMEFRAMES) _Period, 
                                     ma_window_slow, 
                                     ma_window_fast, 
                                     ma_shift, 
                                     ma_method, 
                                     ma_price_type)){
      buy_signals++;
      Print("Found MA buy signal.");
   }
   
   // Check for stochastic oscillator signal
   if (use_stochastic_signals && StochasticBuySignal(_Symbol, 
                                                     (ENUM_TIMEFRAMES) _Period,
                                                     stochastic_k_period,
                                                     stochastic_d_period,
                                                     stochastic_slowing,
                                                     stochastic_ma_method,
                                                     stochastic_price_field,
                                                     stochastic_over_sold_t,
                                                     stochastic_use_atr_volatility_signal)){
      buy_signals++;
      Print("Found Stochastic buy signal.");
   }
   
   // Check for awesome oscillator signal
   if (use_awesome_signals && AwesomeBuySignal(_Symbol,
                                               (ENUM_TIMEFRAMES) _Period,
                                               awesome_saucers_bar_number,
                                               awesome_check_stochastic,
                                               stochastic_k_period,
                                               stochastic_d_period,
                                               stochastic_slowing,
                                               stochastic_ma_method,
                                               stochastic_price_field,
                                               stochastic_over_sold_t)){
      buy_signals++;
      PrintFormat("Found Awesome buy signal with %d open orders.", OrdersTotal());                                                
   }
   
   // Check for ADX signal
   if (use_adx_signals && ADXBuySignal(_Symbol,
                                       (ENUM_TIMEFRAMES) _Period,
                                       adx_period,
                                       adx_price_type,
                                       adx_min_market_trending_t,
                                       adx_use_parabolic_signal,
                                       parabolic_step, 
                                       parabolic_max_step)){
      buy_signals++;
      Print("Found ADX buy signal.");                                        
   }

   // Check for Bollinger bands signal
   if (use_bollinger_signals && BollingerBandsBuySignal(_Symbol,
                                                        (ENUM_TIMEFRAMES) _Period,
                                                        bollinger_period,
                                                        bollinger_std_factor,
                                                        bollinger_shift,
                                                        bollinger_price_type,
                                                        bollinger_squeeze_t,
                                                        adx_period,
                                                        adx_price_type,
                                                        adx_min_market_trending_t)){
      buy_signals++;
      Print("Found Bollinger buy signal.");
   }
   
   /*// Check for parabolic SAR signal
   if (use_parabolic_signals && ParabolicSARBuySignal(_Symbol,
                                                      (ENUM_TIMEFRAMES) _Period,
                                                      parabolic_step,
                                                      parabolic_max_step,
                                                      parabolic_use_adx_trending_signal,
                                                      adx_period,
                                                      adx_price_type,
                                                      adx_min_market_trending_t,
                                                      adx_max_market_trending_t)){
      buy_signals++;
      Print("Found Parabolic SAR buy signal.");                                           
   }*/
   
   
   return buy_signals;
}


//+------------------------------------------------------------------+
//| Sell signal check function                                       |
//+------------------------------------------------------------------+
int CheckSellSignals(){
   int sell_signals = 0;
   
   // Check for MA signal
   if (use_ma_signals && MASellSignal(_Symbol,
                                      (ENUM_TIMEFRAMES) _Period, 
                                      ma_window_slow, 
                                      ma_window_fast, 
                                      ma_shift, 
                                      ma_method, 
                                      ma_price_type)){
      sell_signals++;
      Print("Found MA sell signal.");
   }
   
   // Check for stochastic oscillator signal
   if (use_stochastic_signals && StochasticSellSignal(_Symbol, 
                                                      (ENUM_TIMEFRAMES) _Period,
                                                      stochastic_k_period,
                                                      stochastic_d_period,
                                                      stochastic_slowing,
                                                      stochastic_ma_method,
                                                      stochastic_price_field,
                                                      stochastic_over_bought_t,
                                                      stochastic_use_atr_volatility_signal)){
      sell_signals++;
      Print("Found Stochastic sell signal.");
   }
   
   // Check for awesome oscillator signal
   if (use_awesome_signals && AwesomeSellSignal(_Symbol,
                                                (ENUM_TIMEFRAMES) _Period,
                                                awesome_saucers_bar_number,
                                                awesome_check_stochastic,
                                                stochastic_k_period,
                                                stochastic_d_period,
                                                stochastic_slowing,
                                                stochastic_ma_method,
                                                stochastic_price_field,
                                                stochastic_over_bought_t)){
      sell_signals++;
      PrintFormat("Found Awesome sell signal %d open orders.", OrdersTotal());                                          
   }
   
   // Check for ADX signal
   if (use_adx_signals && ADXSellSignal(_Symbol,
                                        (ENUM_TIMEFRAMES) _Period,
                                        adx_period,
                                        adx_price_type,
                                        adx_min_market_trending_t,
                                        adx_use_parabolic_signal, 
                                        parabolic_step, 
                                        parabolic_max_step)){
      sell_signals++;
      Print("Found ADX sell signal.");                                        
   }
   
   // Check for Bollinger bands signal
   if (use_bollinger_signals && BollingerBandsSellSignal(_Symbol,
                                                         (ENUM_TIMEFRAMES) _Period,
                                                         bollinger_period,
                                                         bollinger_std_factor,
                                                         bollinger_shift,
                                                         bollinger_price_type,
                                                         bollinger_squeeze_t,
                                                         adx_period,
                                                         adx_price_type,
                                                         adx_min_market_trending_t)){
      sell_signals++;
      Print("Found Bollinger sell signal.");
   }
   
   // Check for parabolic SAR signal
   /*if (use_parabolic_signals && ParabolicSARSellSignal(_Symbol,
                                                       (ENUM_TIMEFRAMES) _Period,
                                                       parabolic_step,
                                                       parabolic_max_step,
                                                       parabolic_use_adx_trending_signal,
                                                       adx_period,
                                                       adx_price_type,
                                                       adx_min_market_trending_t,
                                                       adx_max_market_trending_t)){
      sell_signals++;
      Print("Found Parabolic SAR sell signal.");                                           
   }*/
   
   
   return sell_signals;
}
  
/*//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol){
   int buys = 0, sells = 0;
   //---
   for(int i = 0; i < OrdersTotal(); i++){
      if (!OrderSelect(i, SELECT_BY_POS,MODE_TRADES)) 
         break;
         
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MAGICMA){
         if (OrderType() == OP_BUY)
            buys++;
         if (OrderType() == OP_SELL)
            sells++;
      }
   }
   
   //--- return orders volume
   if (buys > 0) 
      return buys;
   else
      return -sells;
}*/


//+------------------------------------------------------------------+
//| MA buy signal function                                           |
//+------------------------------------------------------------------+
bool MABuySignal(string symbol,
                 ENUM_TIMEFRAMES timeframe, 
                 int window_slow = 50, 
                 int window_fast = 20, 
                 int ma_shift_ = 0, 
                 ENUM_MA_METHOD ma_method_ = MODE_EMA, 
                 ENUM_APPLIED_PRICE price_type = PRICE_CLOSE){
   double ma_slow_curr, ma_slow_prev, ma_fast_curr, ma_fast_prev;
              
   // Get slow and fast current and previous MA
   ma_slow_curr = iMA(symbol, timeframe, window_slow, ma_shift_, ma_method_, price_type, 0);
   ma_slow_prev = iMA(symbol, timeframe, window_slow, ma_shift_, ma_method_, price_type, 1);
   ma_fast_curr = iMA(symbol, timeframe, window_fast, ma_shift_, ma_method_, price_type, 0);
   ma_fast_prev = iMA(symbol, timeframe, window_fast, ma_shift_, ma_method_, price_type, 1);
   
   return (ma_slow_prev > ma_fast_prev) && (ma_slow_curr < ma_fast_curr);
}


//+------------------------------------------------------------------+
//| MA sell signal function                                          |
//+------------------------------------------------------------------+
bool MASellSignal(string symbol,
                  ENUM_TIMEFRAMES timeframe, 
                  int window_slow = 50, 
                  int window_fast = 20, 
                  int ma_shift_ = 0, 
                  ENUM_MA_METHOD ma_method_ = MODE_EMA, 
                  ENUM_APPLIED_PRICE price_type = PRICE_CLOSE){
   double ma_slow_curr, ma_slow_prev, ma_fast_curr, ma_fast_prev;
                    
   // Get slow and fast current and previous MA
   ma_slow_curr = iMA(symbol, timeframe, window_slow, ma_shift_, ma_method_, price_type, 0);
   ma_slow_prev = iMA(symbol, timeframe, window_slow, ma_shift_, ma_method_, price_type, 1);
   ma_fast_curr = iMA(symbol, timeframe, window_fast, ma_shift_, ma_method_, price_type, 0);
   ma_fast_prev = iMA(symbol, timeframe, window_fast, ma_shift_, ma_method_, price_type, 1);
   
   return (ma_slow_prev < ma_fast_prev) && (ma_slow_curr > ma_fast_curr);
}


//+------------------------------------------------------------------+
//| ATR volatility signal based on MA                                |
//+------------------------------------------------------------------+
bool CheckHighVolatilityATR(string symbol, 
                            ENUM_TIMEFRAMES timeframe,
                            int ma_window_ = 50, 
                            int ma_shift_ = 0, 
                            ENUM_MA_METHOD ma_method_ = MODE_SMA, 
                            ENUM_APPLIED_PRICE ma_price_type_ = PRICE_CLOSE,
                            int atr_period_ = 14,
                            double atr_normalized_volatility_t_ = 0.05){
   double ma, atr, normalized_atr;
                               
   // Get ATR and MA value                            
   ma = iMA(symbol, timeframe, ma_window_, ma_shift_, ma_method_, ma_price_type_, 0);
   atr = iATR(symbol, timeframe, atr_period_, 0);
   
   // Normalize ATR as a percentage of the MA
   normalized_atr = atr / ma;
   
   // Check if this percentage is above a certain threshold
   return normalized_atr >= atr_normalized_volatility_t_;            
}


//+------------------------------------------------------------------+
//| Stochastic oscillator buy signal function                        |
//+------------------------------------------------------------------+
bool StochasticBuySignal(string symbol,
                         ENUM_TIMEFRAMES timeframe,
                         int stochastic_k_period_ = 14,
                         int stochastic_d_period_ = 3,
                         int stochastic_slowing_ = 3,
                         ENUM_MA_METHOD stochastic_ma_method_ = MODE_SMA,
                         int stochastic_price_field_ = 0,
                         double stochastic_over_sold_t_ = 20,
                         bool use_atr_volatility_signal_ = true) {
   double stochastic_k_curr, stochastic_d_curr, stochastic_k_prev1, stochastic_d_prev1, stochastic_k_prev2, stochastic_d_prev2, price_low_curr, price_low_prev1, price_low_prev2;
                            
   // Get the current and previous two stochastic oscillator values                     
   stochastic_k_curr = iStochastic(symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_MAIN, 0);
   stochastic_d_curr = iStochastic(symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_SIGNAL, 0);
   stochastic_k_prev1 = iStochastic(symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_MAIN, 1);
   stochastic_d_prev1 = iStochastic(symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_SIGNAL, 1);
   stochastic_k_prev2 = iStochastic(symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_MAIN, 2);
   stochastic_d_prev2 = iStochastic(symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_SIGNAL, 2);                      
   
   // If volatility is too high, don't buy
   if (use_atr_volatility_signal_ && CheckHighVolatilityATR(symbol, timeframe, 14))
      return false;
   
   // If we are in an oversold phase, use the crossover signal
   if ((stochastic_d_prev2 < stochastic_over_sold_t_) && (stochastic_k_prev2 < stochastic_over_sold_t_)){
      
      // Buy if %K line crossed the %D line by below at the previous timestep and thecurrent %D line is rising (the current %D line is higher than the previous)
      if ((stochastic_d_prev2 > stochastic_k_prev2) && (stochastic_d_prev1 < stochastic_k_prev1)){
      
         return stochastic_d_prev1 < stochastic_d_curr;
      }
   }
   
   // If we are not in an oversold phase, use the divergence signal: price makes a lower low, but %K makes a higher low
   else {
      // Get the current and previous two price lows
      price_low_curr = Low[0];
      price_low_prev1 = Low[1];
      price_low_prev2 = Low[2];
      
      // Buy if price makes a lower low, but %K makes a higher low
      if ((price_low_curr < price_low_prev1) && (price_low_prev1 < price_low_prev2) && (stochastic_k_curr > stochastic_k_prev1) && (stochastic_k_prev1 > stochastic_k_prev2)){
      
         return true;
      }
   }
   
   // Otherwise, no buy signal
   return false;
}


//+------------------------------------------------------------------+
//| Stochastic oscillator sell signal function                       |
//+------------------------------------------------------------------+
bool StochasticSellSignal(string symbol,
                         ENUM_TIMEFRAMES timeframe,
                         int stochastic_k_period_ = 14,
                         int stochastic_d_period_ = 3,
                         int stochastic_slowing_ = 3,
                         ENUM_MA_METHOD stochastic_ma_method_ = MODE_SMA,
                         int stochastic_price_field_ = 0,
                         double stochastic_over_bought_t_ = 80,
                         bool use_atr_volatility_signal_ = true) {
   double stochastic_k_curr, stochastic_d_curr, stochastic_k_prev1, stochastic_d_prev1, stochastic_k_prev2, stochastic_d_prev2, price_high_curr, price_high_prev1, price_high_prev2;
                               
   // Get the current and previous two stochastic oscillator values                     
   stochastic_k_curr = iStochastic (symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_MAIN, 0);
   stochastic_d_curr = iStochastic (symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_SIGNAL, 0);
   stochastic_k_prev1 = iStochastic (symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_MAIN, 1);
   stochastic_d_prev1 = iStochastic (symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_SIGNAL, 1);
   stochastic_k_prev2 = iStochastic (symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_MAIN, 2);
   stochastic_d_prev2 = iStochastic (symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_SIGNAL, 2);                      
   
   // If volatility is too high, don't sell
   if (use_atr_volatility_signal_ && CheckHighVolatilityATR(symbol, timeframe, 14))
      return false;
   
   // If we are in an overbought phase, use the crossover signal
   if ((stochastic_d_prev2 > stochastic_over_bought_t_) && (stochastic_k_prev2 > stochastic_over_bought_t_)){
      
      // Buy if %K line crossed the %D line from above at the previous timestep and thecurrent %D line is rising (the current %D line is higher than the previous)
      if ((stochastic_d_prev2 < stochastic_k_prev2) && (stochastic_d_prev1 > stochastic_k_prev1)){
      
         return stochastic_d_prev1 > stochastic_d_curr;
      }
   }
   
   // If we are not in an overbought phase, use the divergence signal: price makes a higher high, but %K makes a lower high
   else {
      // Get the current and previous two price highs
      price_high_curr = High[0];
      price_high_prev1 = High[1];
      price_high_prev2 = High[2];
      
      // Sell if price makes a higher high, but %K makes a lower high
      if ((price_high_curr > price_high_prev1) && (price_high_prev1 > price_high_prev2) && (stochastic_k_curr < stochastic_k_prev1) && (stochastic_k_prev1 < stochastic_k_prev2)){
      
         return true;
      }
   }
   
   // Otherwise, no sell signal
   return false;
   
}


//+------------------------------------------------------------------+
//| Awesome oscillator buy signal function                           |
//+------------------------------------------------------------------+
bool AwesomeBuySignal(string symbol,
                      ENUM_TIMEFRAMES timeframe,
                      int awesome_saucers_bar_number_ = 3,
                      bool check_stochastic_oversold_ = true,
                      int stochastic_k_period_ = 14,
                      int stochastic_d_period_ = 3,
                      int stochastic_slowing_ = 3,
                      ENUM_MA_METHOD stochastic_ma_method_ = MODE_SMA,
                      int stochastic_price_field_ = 0,
                      double stochastic_over_sold_t_ = 20) {
   double stochastic_k, stochastic_d, aws_curr, aws_prev1, aws_prev2;
                            
   // Get the current and previous two stochastic oscillator values                     
   stochastic_k = iStochastic(symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_MAIN, 0);
   stochastic_d = iStochastic(symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_SIGNAL, 0);                      
   
   // If we aren't in an oversold phase, and we use stochastic oscillator, don't buy
   if (check_stochastic_oversold_ && !((stochastic_k < stochastic_over_sold_t_))) // && (stochastic_d < stochastic_over_sold_t_)))
      return false;
      
   // Check bullish saucer: awesome oscillator is positive, we had k consecutive red (diminishing) awesome values and a green (increasing) value
   aws_curr = iAO(symbol, timeframe, 0);
   aws_prev1 = iAO(symbol, timeframe, 1);
   
   // If awesome oscillator is negative, don't buy
   if (aws_prev1 < 0 || aws_curr < 0)
      return false;
   
   // Check diminishing awesome values 
   for (int i = awesome_saucers_bar_number_ + 1; i > 2; i--){
      aws_prev1 = iAO(symbol, timeframe, i - 1);
      aws_prev2 = iAO(symbol, timeframe, i);
      
      if (aws_prev2 < aws_prev1)  // Consecutive not diminishing
         return false;
   }
   
   // Check if the previous awesome value is higher than the one preceding that
   aws_prev1 = iAO(symbol, timeframe, 1);
   aws_prev2 = iAO(symbol, timeframe, 2);
   
   if (aws_prev2 > aws_prev1)  // Last not increasing
      return false;
   
   /*
   Print("Stochastic D: ", stochastic_d, " Stochastic K: ", stochastic_k, " Checked values: ");
   for (i = awesome_saucers_bar_number_ + 1; i > 2; i--){
      aws_prev1 = iAO(symbol, timeframe, i - 1);
      aws_prev2 = iAO(symbol, timeframe, i);
         
      Print("Found iAO(", i, ") ", aws_prev2, " > ", " iAO(", i - 1, ") ", aws_prev1);
   }
   
   aws_prev1 = iAO(symbol, timeframe, 1);
   aws_prev2 = iAO(symbol, timeframe, 2);
   Print("Found iAO(", 2, ") ", aws_prev2, " < ", " iAO(", 1, ") ", aws_prev1);
   */
   
   // If we passed the controls then we are under bullish saucer conditions
   return true;
}


//+------------------------------------------------------------------+
//| Awesome oscillator sell signal function                          |
//+------------------------------------------------------------------+
bool AwesomeSellSignal(string symbol,
                       ENUM_TIMEFRAMES timeframe,
                       int awesome_saucers_bar_number_ = 3,
                       bool check_stochastic_overbought_ = true,
                       int stochastic_k_period_ = 14,
                       int stochastic_d_period_ = 3,
                       int stochastic_slowing_ = 3,
                       ENUM_MA_METHOD stochastic_ma_method_ = MODE_SMA,
                       int stochastic_price_field_ = 0,
                       double stochastic_over_bought_t_ = 80,
                       bool use_atr_volatility_signal_ = true) {
   double stochastic_k, stochastic_d, aws_curr, aws_prev1, aws_prev2;
                            
   // Get the current and previous two stochastic oscillator values                     
   stochastic_k = iStochastic(symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_MAIN, 0);
   stochastic_d = iStochastic(symbol, timeframe, stochastic_k_period_, stochastic_d_period_, stochastic_slowing_, stochastic_ma_method_, stochastic_price_field_, MODE_SIGNAL, 0);                      
   
   // If we aren't in an overbought phase, and we use stochastic oscillator, don't buy
   if (check_stochastic_overbought_ && !((stochastic_k > stochastic_over_bought_t_))) //&& (stochastic_d > stochastic_over_bought_t_)))
      return false;
      
   // Check bullish saucer: awesome oscillator is positive, we had k consecutive red (diminishing) awesome values and a green (increasing) value
   aws_curr = iAO(symbol, timeframe, 0);
   aws_prev1 = iAO(symbol, timeframe, 1);
   
   // If awesome oscillator is positive, don't sell
   if (aws_prev1 > 0 || aws_curr > 0)
      return false;
   
   // Check increasing awesome values 
   for (int i = awesome_saucers_bar_number_ + 1; i > 2; i--){
      aws_prev1 = iAO(symbol, timeframe, i - 1);
      aws_prev2 = iAO(symbol, timeframe, i);
      
      if (aws_prev2 > aws_prev1)  // Consecutive not increasing
         return false;
   }
   
   // Check if the previous awesome value is lower than the one preceding that
   aws_prev1 = iAO(symbol, timeframe, 1);
   aws_prev2 = iAO(symbol, timeframe, 2);
   
   if (aws_prev2 < aws_prev1)  // Last not diminishing
      return false;
   
   /*
   Print("Stochastic D: ", stochastic_d, " Stochastic K: ", stochastic_k, " Checked values: ");
   for (i = awesome_saucers_bar_number_ + 1; i > 2; i--){
      aws_prev1 = iAO(symbol, timeframe, i - 1);
      aws_prev2 = iAO(symbol, timeframe, i);
         
      Print("Found iAO(", i, ") ", aws_prev2, " < ", " iAO(", i - 1, ") ", aws_prev1);
   }
   
   aws_prev1 = iAO(symbol, timeframe, 1);
   aws_prev2 = iAO(symbol, timeframe, 2);
   Print("Found iAO(", 2, ") ", aws_prev2, " > ", " iAO(", 1, ") ", aws_prev1);
   */
   
   // If we passed the controls then we are under bearish saucer conditions
   return true;
}


//+------------------------------------------------------------------+
//| ADX buy signal function                                          |
//+------------------------------------------------------------------+
bool ADXBuySignal(string symbol,
                  ENUM_TIMEFRAMES timeframe,
                  int adx_period_ = 14,
                  ENUM_APPLIED_PRICE adx_price_type_ = PRICE_CLOSE,
                  double adx_min_market_trending_t_ = 20.0,
                  bool adx_use_parabolic_signal_ = true,
                  double parabolic_step_ = 0.02,
                  double parabolic_max_step_ = 0.2){
   double adx_main_curr, adx_di_pos_curr, adx_di_neg_curr, adx_di_pos_prev, adx_di_neg_prev, parabolic_sar;
                     
   // Get current ADX value and current/previous -DI and +DI values                 
   adx_main_curr = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_MAIN, 0);
   adx_di_pos_curr = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_PLUSDI, 0);
   adx_di_neg_curr = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_MINUSDI, 0);
   adx_di_pos_prev = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_PLUSDI, 1);
   adx_di_neg_prev = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_MINUSDI, 1);
   
   // Check if the market is sufficently trending, if not, don't buy
   if (adx_main_curr < adx_min_market_trending_t_)
      return false;
      
   // If required, check if the parabolic SAR line is below the Bid price (don't buy if not)
   parabolic_sar = iSAR(symbol, timeframe, parabolic_step_, parabolic_max_step_, 0);
   if (adx_use_parabolic_signal_ && parabolic_sar > Bid)
      return false;
      
   // Check for a crossing between the +DI/-DI lines from below
   if (adx_di_pos_prev < adx_di_neg_prev && adx_di_pos_curr > adx_di_neg_curr)
      return true;
      
   return false;     
}
                  

//+------------------------------------------------------------------+
//| ADX sell signal function                                         |
//+------------------------------------------------------------------+
bool ADXSellSignal(string symbol,
                  ENUM_TIMEFRAMES timeframe,
                  int adx_period_ = 14,
                  ENUM_APPLIED_PRICE adx_price_type_ = PRICE_CLOSE,
                  double adx_min_market_trending_t_ = 20.0,
                  bool adx_use_parabolic_signal_ = true,
                  double parabolic_step_ = 0.02,
                  double parabolic_max_step_ = 0.2){
   double adx_main_curr, adx_di_pos_curr, adx_di_neg_curr, adx_di_pos_prev, adx_di_neg_prev, parabolic_sar;
                     
   // Get current ADX value and current/previous -DI and +DI values                 
   adx_main_curr = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_MAIN, 0);
   adx_di_pos_curr = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_PLUSDI, 0);
   adx_di_neg_curr = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_MINUSDI, 0);
   adx_di_pos_prev = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_PLUSDI, 1);
   adx_di_neg_prev = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_MINUSDI, 1);
   
   // Check if the market is sufficently trending, if not, don't sell
   if (adx_main_curr < adx_min_market_trending_t_)
      return false;
      
   // If required, check if the parabolic SAR line is above the Ask price (don't sell if not)
   parabolic_sar = iSAR(symbol, timeframe, parabolic_step_, parabolic_max_step_, 0);
   if (adx_use_parabolic_signal_ && parabolic_sar < Ask)
      return false;
      
   // Check for a crossing between the -DI/+DI lines from below
   if (adx_di_neg_prev < adx_di_pos_prev && adx_di_neg_curr > adx_di_pos_curr)
      return true;
      
   return false;  
}

//+------------------------------------------------------------------+
//| Bollinger Bands buy signal function                              |
//+------------------------------------------------------------------+
bool BollingerBandsBuySignal(string symbol,
                             ENUM_TIMEFRAMES timeframe,
                             int bollinger_period_,
                             double bollinger_std_factor_,
                             int bollinger_shift_,
                             ENUM_APPLIED_PRICE bollinger_price_type_,
                             double bollinger_squeeze_t_,
                             int adx_period_,
                             ENUM_APPLIED_PRICE adx_price_type_,
                             double adx_min_market_trending_t_){
   double adx_main_curr, band_mid, band_up, band_up_prev1, band_up_prev2, band_low_prev1, band_low_prev2, band_low, price, price_prev1, price_prev2, squeeze;
                              
   // Get current ADX value to check market trending               
   adx_main_curr = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_MAIN, 0);
   Print("ADX: ", adx_main_curr);
                              
   // Check if the market is sufficently trending, if not, don't buy
   if (adx_main_curr < adx_min_market_trending_t_)
      return false;
  
  // Get the value of bollinger bands   
  band_mid = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_MAIN, 0);
  band_up = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_UPPER, 0);
  band_low = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_LOWER, 0);
  
  // Squeeze signal: bands are narrow and the price crossed the upper band
  price = Bid;
  squeeze = (band_up - band_low) / band_mid;
  
  /*if (squeeze >= bollinger_squeeze_t_ && price_prev1 > band_up && price <= band_up)
   return true;
  
  // Mean reversion signal: price went upper than the upper band and then crossed down the mean
  band_up_prev1 = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_UPPER, 1);
  band_up_prev2 = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_UPPER, 2);
  price_prev1 = iClose(symbol, timeframe, 1);         
  price_prev2 = iClose(symbol, timeframe, 2);
  
  if ((price_prev2 > band_up_prev2 && price_prev1 <= band_up_prev1 && price < band_mid) || (price_prev2 < band_up_prev2 && price_prev1 > band_up_prev1 && price < band_mid))
   return true;*/
  if (squeeze >= bollinger_squeeze_t_ && price_prev1 < band_low && price >= band_low)
   return true;
  
  // Mean reversion signal: price went upper than the upper band and then crossed down the mean
  band_low_prev1 = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_LOWER, 1);
  band_low_prev2 = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_LOWER, 2);
  price_prev1 = iClose(symbol, timeframe, 1);         
  price_prev2 = iClose(symbol, timeframe, 2);
  
  if ((price_prev2 < band_low_prev2 && price_prev1 >= band_low_prev1 && price > band_mid) || (price_prev2 > band_low_prev2 && price_prev1 < band_low_prev1 && price > band_mid))
   return true;
   
  return false;                  
}


//+------------------------------------------------------------------+
//| Bollinger Bands sell signal function                              |
//+------------------------------------------------------------------+
bool BollingerBandsSellSignal(string symbol,
                              ENUM_TIMEFRAMES timeframe,
                              int bollinger_period_,
                              double bollinger_std_factor_,
                              int bollinger_shift_,
                              ENUM_APPLIED_PRICE bollinger_price_type_,
                              double bollinger_squeeze_t_,
                              int adx_period_,
                              ENUM_APPLIED_PRICE adx_price_type_,
                              double adx_min_market_trending_t_){
   double adx_main_curr, band_mid, band_up, band_low, band_low_prev1, band_low_prev2, band_up_prev1, band_up_prev2, price, price_prev1, price_prev2, squeeze;
                              
   // Get current ADX value to check market trending               
   adx_main_curr = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_MAIN, 0);
   Print("ADX: ", adx_main_curr);
                              
   // Check if the market is sufficently trending, if not, don't sell
   if (adx_main_curr < adx_min_market_trending_t_)
      return false;
  
  // Get the value of bollinger bands   
  band_mid = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_MAIN, 0);
  band_up = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_UPPER, 0);
  band_low = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_LOWER, 0);
  
  // Squeeze signal: bands are narrow and the price crossed the lower band
  price = Ask;
  squeeze = (band_up - band_low) / band_mid;
  
  /*
  if (squeeze >= bollinger_squeeze_t_ && price_prev1 < band_low && price >= band_low)
   return true;
  
  // Mean reversion signal: price went upper than the upper band and then crossed down the mean
  band_low_prev1 = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_LOWER, 1);
  band_low_prev2 = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_LOWER, 2);
  price_prev1 = iClose(symbol, timeframe, 1);         
  price_prev2 = iClose(symbol, timeframe, 2);
  
  if ((price_prev2 < band_low_prev2 && price_prev1 >= band_low_prev1 && price > band_mid) || (price_prev2 > band_low_prev2 && price_prev1 < band_low_prev1 && price > band_mid))
   return true; */
   
  if (squeeze >= bollinger_squeeze_t_ && price_prev1 > band_up && price <= band_up)
   return true;
  
  // Mean reversion signal: price went upper than the upper band and then crossed down the mean
  band_up_prev1 = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_UPPER, 1);
  band_up_prev2 = iBands(symbol, timeframe, bollinger_period_, bollinger_std_factor_, bollinger_shift_, bollinger_price_type, MODE_UPPER, 2);
  price_prev1 = iClose(symbol, timeframe, 1);         
  price_prev2 = iClose(symbol, timeframe, 2);
  
  if ((price_prev2 > band_up_prev2 && price_prev1 <= band_up_prev1 && price < band_mid) || (price_prev2 < band_up_prev2 && price_prev1 > band_up_prev1 && price < band_mid))
   return true;
   
  return false;                  
}


/*//+------------------------------------------------------------------+
//| Parabolic SAR buy signal function                                         |
//+------------------------------------------------------------------+
bool ParabolicSARBuySignal(string symbol,
                           ENUM_TIMEFRAMES timeframe,
                           double parabolic_step_,
                           double parabolic_max_step_,
                           double parabolic_use_adx_trending_signal_,
                           int adx_period_,
                           ENUM_APPLIED_PRICE adx_price_type_,
                           double adx_min_market_trending_t_,
                           double adx_max_market_trending_t_){
   double adx_main_curr;
                              
   // Get current ADX value to check market trending               
   adx_main_curr = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_MAIN, 0);
                              
   // Check if the market is sufficently trending, if not, don't buy
   if (adx_main_curr < adx_min_market_trending_t_)
      return false;
      
  // Check if the market is too much trending, if so, don't buy
   if (adx_main_curr > adx_max_market_trending_t_)
      return false;                                                
}


//+------------------------------------------------------------------+
//| Parabolic SAR sell signal function                                         |
//+------------------------------------------------------------------+
bool ParabolicSARSellSignal(string symbol,
                            ENUM_TIMEFRAMES timeframe,
                            double parabolic_step_,
                            double parabolic_max_step_,
                            double parabolic_use_adx_trending_signal_,
                            int adx_period_,
                            ENUM_APPLIED_PRICE adx_price_type_,
                            double adx_min_market_trending_t_,
                            double adx_max_market_trending_t_){
   double adx_main_curr;
                               
   // Get current ADX value to check market trending               
   adx_main_curr = iADX(symbol, timeframe, adx_period_, adx_price_type_, MODE_MAIN, 0);
   
   // Check if the market is sufficently trending, if not, don't sell
   if (adx_main_curr < adx_min_market_trending_t_)
      return false;                            
   
   // Check if the market is too much trending, if so, don't sell
   if (adx_main_curr > adx_max_market_trending_t_)
      return false;                                                      
}*/

 
//+------------------------------------------------------------------+
//| ATR-based Stop-Loss function                                     |
//+------------------------------------------------------------------+
double ATRStopLoss(string symbol, 
                   ENUM_TIMEFRAMES timeframe,
                   double point_val, 
                   int period, 
                   double atr_factor,
                   double order_open_price, 
                   ENUM_ORDER_TYPE order_type){
 
   double stop_loss = -1.0, atr;
   
   // Get ATR value
   atr = iATR(symbol, timeframe, period, 0);
   
   // Calculate stop-loss price based on ATR
   if (order_type == OP_BUY){ // For long positions
     stop_loss = order_open_price - atr * atr_factor * point_val; // Stop loss below entry price
   }
   else if (order_type == OP_SELL){ // For short positions
     stop_loss = order_open_price + atr * atr_factor * point_val; // Stop loss above entry price
   }
   return stop_loss;
}

//+------------------------------------------------------------------+
//| ATR-based Take-Profit function                                   |
//+------------------------------------------------------------------+
double ATRTakeProfit(string symbol, 
                     ENUM_TIMEFRAMES timeframe,
                     double point_val, 
                     int period,
                     double atr_factor,
                     double order_open_price, 
                     ENUM_ORDER_TYPE order_type){
 
   double take_profit = -1.0, atr;
   
   // Get ATR value
   atr = iATR(symbol, timeframe, period, 0);
   
   // Calculate take-profit price based on ATR
   if (order_type == OP_BUY){ // For long positions
     take_profit = order_open_price + atr * atr_factor * point_val; // Take profit above entry price
   }
   else if (order_type == OP_SELL){ // For short positions
     take_profit = order_open_price - atr * atr_factor * point_val; // Take profit below entry price
   }
   return take_profit;
}
 
//+------------------------------------------------------------------+
//| Optimized lot size calculating function                          |
//+------------------------------------------------------------------+
double LotsOptimized(ENUM_ORDER_TYPE order_type, string order_symbol, double stop_loss){

   double optimal_lot = lot, n_tick_value;
   int orders = HistoryTotal(); // history orders total
   int losses = 0; // number of losses orders without a break
   
   // Use tick value to normalize stop_loss
   n_tick_value = MarketInfo(_Symbol, MODE_TICKVALUE);
   if (_Digits == 3 || _Digits == 5)
      n_tick_value *= 10;
   
   // Select lot size based on stop-loss
   if (stop_loss > 0)
      optimal_lot = NormalizeDouble(AccountFreeMargin() * max_risk / (stop_loss * n_tick_value), 2);
   else
      optimal_lot = NormalizeDouble(AccountFreeMargin() * max_risk / 1000.0, 2);
   
   // Calculate number of losses orders without a break and adjiust lot size according to it and the input decrease factor
   if (lot_decrease_factor > 0){
      for(int i = orders - 1; i >= 0; i--){
         if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false){
            Print("Error in history!");
            break;
         }
         
         if (OrderSymbol() != Symbol() || OrderType() > OP_SELL)
            continue;
         //---
         if (OrderProfit() > 0)
            break;
           
         if (OrderProfit() < 0)
            losses++;
      }
      
      if (losses > 1)
         optimal_lot = NormalizeDouble(optimal_lot - optimal_lot * losses / lot_decrease_factor, 2);
   }
   // Return lot size (minimum 0.1, max 1.0)
   if(optimal_lot < 0.1) 
      optimal_lot = 0.1;
   
   // Adjust lot size according to step
   optimal_lot = NormalizeDouble(optimal_lot, 2);
     
   return optimal_lot;
}


//+------------------------------------------------------------------+
//| Make-order function                                              |
//+------------------------------------------------------------------+
bool MakeOrder(ENUM_ORDER_TYPE order_type){
  int ticket;
  double price, price_sl, price_tp, sl, tp, optimal_lot;
  color col;
  
  RefreshRates();
  
  // Check the order type and set the order parameters
  if (order_type == OP_BUY){ // For long positions
    price = Ask;
    price_sl = Bid;
    price_tp = Ask;
    col = clrAliceBlue;
  }
  
  else if (order_type == OP_SELL){ // For short positions
    price = Bid; // Sell at the bid price
    price_sl = Ask;
    price_tp = Bid;
    col = clrOrangeRed;
  }
    
  else { // Invalid order type
    Print("Error: Invalid order type!");
    return false;
  }
  
  // Set the stop loss below the entry price for short positions, above for long positions
  sl = ATRStopLoss(_Symbol, (ENUM_TIMEFRAMES) _Period, _Point, atr_window, atr_stop_loss_factor, price_sl, order_type);  
  
  // Set the take profit below the entry price for short positions, above for long positions
  tp = ATRTakeProfit(_Symbol, (ENUM_TIMEFRAMES) _Period, _Point, atr_window, atr_take_profit_factor, price_tp, order_type);
  
  // Check if computed sl and tp are too close to price using stop_level
  if (order_type == OP_BUY){ // For long positions
    double max_sl = price_sl - stop_level * _Point;
    double min_tp = price_tp + stop_level * _Point;
    
    
    if (sl > max_sl)
      sl = max_sl;
    if (tp < min_tp)
      tp = min_tp;
  }
  else if (order_type == OP_SELL){
    double min_sl = price_sl + stop_level * _Point;
    double max_tp = price_tp - stop_level * _Point;
    
    if (sl < min_sl)
      sl = min_sl;
    if (tp > max_tp)
      tp = max_tp;
  }
  
  // Calculate the optimal lot size if required
  if (optimize_lot)
      optimal_lot = LotsOptimized(order_type, _Symbol, sl);
  else
      optimal_lot = lot;
 
  // Execute the order
  if (verbose_log)
     Print("Order params: \n", " Symbol: ", _Symbol, " Order type: ", order_type, " Lot: ", optimal_lot, " Price: ",
           price, " Price slippage: ", price_slippage, " SL: ", sl, " TP: ", tp, " Comment: ", "", " Magic number: ", MAGICMA, " Datetime expiration: ", 0, " Color: ", col);
           
  ticket = OrderSend(_Symbol, order_type, optimal_lot, price, price_slippage, sl, tp, "", MAGICMA, 0, col);
  
  if (ticket < 0){ // Order failed
    Print("Error: Order failed! Error code: ", GetLastError());
    return false;
  }
  
  // Order succeeded
  Print("Success: Order executed! Ticket: ", ticket);
  return true;
}
