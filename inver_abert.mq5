//+------------------------------------------------------------------+
//|                                                        rsi_2.mq5 |
//|                                                     Émeson Filho |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Émeson Filho"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh> // Biblioteca
#include <Arrays\List.mqh>
#include <generic/hashmap.mqh>
#include "config/auto_load.mqh"


//CTrade trade;

double               ask, bid, last;
double               open,high,low,close,preco_corrente;
double               lancar_compra, lancar_venda;
int                  valor_compra_dia, valor_venda_dia;
int                  resto_compra, resto_venda;
int                  operacoes_dia;

MqlRates             rates[];
MqlTick             ultimoTick;
MqlDateTime         horaAtual;

bool                posAberta;
bool                ordPendente;
bool                beAtivo;
bool                autorizar_operacao;

double              PCR;
double              STL;
double              TKP;

//--- VARIÁVEIS EM RELAÇÃO A DATA
int today;
int i = 0;




sinput string s0; // MONITORAMENTO DO OPERACIONAL

input ENUM_ORDER_TYPE_FILLING tipoOrdem = ORDER_FILLING_FOK; // Tipo de ordem
input int lotes = 1; // Quantidade de lotes
input double ganho = 0; // Pontos de gain
input double perda = 0; // Pontos de loss
input int OPERACOES_DIA = 1; // Quantidade de operações por dia
input ulong desvioEntrada = 5; //  Desvio   máximo nos pontos de entrada
input float PONTOS_GATILHOS = 100;

sinput string s1; // AVANÇOS NA OPERAÇÃO

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input double gatilhoBE = 0; // Gatilho BreakEven  (0 = Desativado)
input double gatilhoTS = 0; // Gatilho TraillingStop (0 = Desativado)
input double stepTS = 0; // Step TraillingStop

sinput string s2; // HORÁRIOS PARA MONITORAMENTO

input int horaInicioAbertura = 9; // Hora de início das aberturas de posições
input int minutoInicioAbertura = 10; // Minuto de início das aberturas de posições
input int horaFimAbertura = 16; // Hora de encerramento das aberturas de posições
input int minutoFimAbertura = 45; // Minuto de encerramento das aberturas de posições
input int horaInicioFechamento = 17; // Hora de início do fechamento das posições
input int minutoInicioFechamnto = 20; // Hora de início do fechamento das posições
input ulong magicNumber = 202006; // Número mágico do robô



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   today = Useful::getDay();

   trade.SetTypeFilling(tipoOrdem);
   trade.SetDeviationInPoints(desvioEntrada);
   trade.SetExpertMagicNumber(magicNumber);

   if(horaInicioAbertura > horaFimAbertura || horaFimAbertura > horaInicioFechamento)
     {
      Alert("Inconsistência de horários de negociação");
      return(INIT_FAILED);

     }

   if(horaInicioAbertura == horaFimAbertura && minutoInicioAbertura >= minutoFimAbertura)
     {
      Alert("Inconsistência de horários de negociação");
      return(INIT_FAILED);


     }

   if(horaFimAbertura == horaInicioFechamento && minutoFimAbertura >= minutoInicioFechamnto)
     {
      Alert("Inconsistência de horários de negociação");
      return(INIT_FAILED);


     }



   return(INIT_SUCCEEDED);
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(CopyRates(_Symbol,PERIOD_D1,0,3,rates)==3)
     {
      open=rates[1].open;
      high=rates[1].high;
      low=rates[1].low;
      close=rates[1].close;

     };


   if(!SymbolInfoTick(_Symbol, ultimoTick))
     {

      Alert("Erro ao obter informações de preços: ", GetLastError());
      return;

     }


   posAberta = false;
   for(int i = PositionsTotal() - 1; i>=0; i--)
     {

      string Symbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(Symbol == _Symbol && magic == magicNumber)
        {

         posAberta = true;
         break;

        }

     }


   ordPendente = false;
   for(int i = OrdersTotal() - 1; i>=0; i--)
     {

      ulong ticket = OrderGetTicket(i);
      string Symbol = OrderGetString(ORDER_SYMBOL);
      ulong magic = OrderGetInteger(ORDER_MAGIC);
      if(Symbol == _Symbol && magic == magicNumber)
        {

         ordPendente = true;
         break;

        }

     }

   if(HoraFechamento())
     {
      Comment("Horário de fechamento das posições");
      FechamentoPosicao();
     }

   else
      if(HoraNegociacao())
        {
         Comment("Dentro do horário de negociação");
        }
      else
        {
         Comment("Fora do horário de negociação");
         DeletaOrdens();
        }

   if(!posAberta)
     {
      beAtivo = false;
     }
   if(posAberta && !beAtivo)
     {
      BreakEven(ultimoTick.last);
     }

   if(posAberta && beAtivo)
     {
      TraillingStop(ultimoTick.last);
     }
//+------------------------------------------------------------------+
//| ARRUMANDO A QUANTIDADE DE OPERAÇÕES POR DIA
//+------------------------------------------------------------------+
   i =  i + 1;
   if(Useful::isNewDay(today))
     {

      operacoes_dia = 0;
      today = Useful::getDay();

     }



//+------------------------------------------------------------------+
//| CONVERTENDO OS NÚMEROS PARA MÚLTIPLOS DE 5
//+------------------------------------------------------------------+

  

   if(open < close)
     {
      // ONTEM FOI DIA DE ALTA
        
      if(ultimoTick.last + PONTOS_GATILHOS < open  && !posAberta && !ordPendente && HoraNegociacao() && operacoes_dia < OPERACOES_DIA)
        {

         operacoes_dia = operacoes_dia + 1;
         PCR = NormalizeDouble(ultimoTick.bid, _Digits);
         STL = NormalizeDouble(PCR + perda, _Digits);
         TKP = NormalizeDouble(PCR - ganho, _Digits);

         if(trade.Sell(lotes, _Symbol, PCR, STL, TKP, "Venda a mercado"))
           {

            Print("Ordem de venda sem falha. ResultRetcode: ", trade.ResultRetcode(), "RetCodeDescription: ", trade.ResultRetcodeDescription());

           }

         else
           {

            Print("Ordem de venda com falha. ResultRetcode: ", trade.ResultRetcode(), "RetCodeDescription: ", trade.ResultRetcodeDescription());

           }

        }
     }
   if(open > close)
     {
      // ONTEM FOI DIA DE QUEDA

      if(ultimoTick.last + PONTOS_GATILHOS > open  && !posAberta && !ordPendente && HoraNegociacao() && operacoes_dia < OPERACOES_DIA)
        {

         operacoes_dia = operacoes_dia + 1;
         PCR = NormalizeDouble(ultimoTick.ask, _Digits);
         STL = NormalizeDouble(PCR - perda, _Digits);
         TKP = NormalizeDouble(PCR + ganho, _Digits);


         if(trade.Buy(lotes, _Symbol, PCR, STL, TKP, "Compra a mercado"))
           {

            Print("Posição fechada sem falha. ResultRetcode: ", trade.ResultRetcode(), "RetCodeDescription: ", trade.ResultRetcodeDescription());

           }

         else
           {

            Print("Posição fechada com falha. ResultRetcode: ", trade.ResultRetcode(), "RetCodeDescription: ", trade.ResultRetcodeDescription());

           }


        }
     }



  }
//+------------------------------------------------------------------+
//| CANCELAMENTO DE ORDENS PENDENTES
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeletaOrdens()
  {

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      string symbol = OrderGetString(ORDER_SYMBOL);
      ulong magic = OrderGetInteger(ORDER_MAGIC);
      if(symbol == _Symbol && magic == magicNumber)
        {
         if(trade.OrderDelete(ticket))
           {
            Print("Posição fechada sem falha. ResultRetcode: ", trade.ResultRetcode(), "RetCodeDescription: ", trade.ResultRetcodeDescription());
           }
         else
           {
            Print("Posição fechada com falha. ResultRetcode: ", trade.ResultRetcode(), "RetCodeDescription: ", trade.ResultRetcodeDescription());
           }


        }


     }

  }





//+------------------------------------------------------------------+
//| FECHAMENTO DE POSIÇÕES PELO HORÁRIO
//+------------------------------------------------------------------+
void FechamentoPosicao()
  {

   for(int i = PositionsTotal() - 1; i>=0; i--)
     {

      string Symbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(Symbol == _Symbol && magic == magicNumber)
        {
         ulong PositionTicket = PositionGetInteger(POSITION_TICKET);

         if(trade.PositionClose(PositionTicket, desvioEntrada))
           {

            Print("Posição fechada sem falha. ResultRetcode", trade.ResultRetcode(), ", RetcodeDescription", trade.ResultRetcodeDescription());

           }
         else
           {
            Print("Posição fechada com falha. ResultRetcode", trade.ResultRetcode(), ", RetcodeDescription", trade.ResultRetcodeDescription());

           }

        }

     }



  }



//+------------------------------------------------------------------+
//| CHECANDO O HORÁRIO DE FECHAMENTO DAS POSIÇÕES
//+------------------------------------------------------------------+
bool HoraFechamento()
  {
   TimeToStruct(TimeCurrent(), horaAtual);
   if(horaAtual.hour >= horaInicioFechamento)
     {
      if(horaAtual.hour == horaInicioFechamento)
        {

         if(horaAtual.min >= minutoInicioFechamnto)
           {
            return true;
           }
         else
           {
            return false;
           }

        }
      return true;
     }

   return false;

  }



//+------------------------------------------------------------------+
//| CHECANDO O HORÁRIO PARA INÍCIO DE FINAL DAS OPERAÇÕES
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HoraNegociacao()
  {

   TimeToStruct(TimeCurrent(), horaAtual);
   if(horaAtual.hour >= horaInicioAbertura && horaAtual.hour <= horaFimAbertura)
     {
      if(horaAtual.hour == horaInicioAbertura)
        {
         if(horaAtual.min >= minutoInicioAbertura)
           {
            return true;
           }
         else
           {
            return false;
           }
        }

      if(horaAtual.hour == horaFimAbertura)
        {

         if(horaAtual.min <= minutoFimAbertura)
           {
            return true;
           }
         else
           {
            return false;
           }
        }

      return true;
     }

   return false;

  }
//+------------------------------------------------------------------+
//| ADICIONANDO BREAKEVEN
//+------------------------------------------------------------------+
void BreakEven(double preco)
  {
   if(gatilhoBE != 0)
     {
      for(int i = PositionsTotal()-1; i>=0; i--)
        {

         string symbol = PositionGetSymbol(i);
         ulong magic = PositionGetInteger(POSITION_MAGIC);
         if(symbol == _Symbol && magic == magicNumber)
           {

            ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
            double PrecoEntrada = PositionGetDouble(POSITION_PRICE_OPEN);
            double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               if(preco >= (PrecoEntrada + gatilhoBE))
                 {
                  if(trade.PositionModify(PositionTicket, PrecoEntrada, TakeProfitCorrente))
                    {
                     Print("BreakEven sem falha. ResultRetcode", trade.ResultRetcode(), ", RetcodeDescription", trade.ResultRetcodeDescription());
                     beAtivo = true;
                    }
                  else
                    {
                     Print("BreakEven com falha. ResultRetcode", trade.ResultRetcode(), ", RetcodeDescription", trade.ResultRetcodeDescription());
                    }
                 }
              }

            else
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                 {
                  if(preco <= (PrecoEntrada - gatilhoBE))
                    {
                       {
                        if(trade.PositionModify(PositionTicket, PrecoEntrada, TakeProfitCorrente))
                          {
                           Print("BreakEven sem falha. ResultRetcode", trade.ResultRetcode(), ", RetcodeDescription", trade.ResultRetcodeDescription());
                           beAtivo = true;
                          }
                        else
                          {
                           Print("BreakEven com falha. ResultRetcode", trade.ResultRetcode(), ", RetcodeDescription", trade.ResultRetcodeDescription());
                          }
                       }
                    }
                 }

           }

        }

     }
  }

//+------------------------------------------------------------------+
//| ADICIONANDO TRAILING STOP (STOP MÓVEL)
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TraillingStop(double preco)
  {
   if(gatilhoTS != 0)
     {

      for(int i = PositionsTotal() - 1 ; 1>=0; i--)
        {
         string symbol = PositionGetSymbol(i);
         ulong magic = PositionGetInteger(POSITION_MAGIC);
         if(symbol == _Symbol && magic == magicNumber)
           {
            ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
            double StopLossCorrente = PositionGetDouble(POSITION_SL);
            double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               if(preco >= (StopLossCorrente + gatilhoTS))
                 {
                  double novo_SL = NormalizeDouble(StopLossCorrente + stepTS, _Digits);
                  if(trade.PositionModify(PositionTicket, novo_SL, TakeProfitCorrente))
                    {

                     Print("Trailling stop sem falha. ResultRetcode", trade.ResultRetcode(), ", RetcodeDescription", trade.ResultRetcodeDescription());

                    }
                  else
                    {
                     Print("Trailling stop com falha. ResultRetcode", trade.ResultRetcode(), ", RetcodeDescription", trade.ResultRetcodeDescription());
                    }
                 }
              }

            else
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
                 {
                  if(preco <= (StopLossCorrente - gatilhoTS))
                    {
                     double novo_SL = NormalizeDouble(StopLossCorrente - stepTS, _Digits);
                     if(trade.PositionModify(PositionTicket, novo_SL, TakeProfitCorrente))
                       {

                        Print("Trailling stop sem falha. ResultRetcode", trade.ResultRetcode(), ", RetcodeDescription", trade.ResultRetcodeDescription());

                       }
                     else
                       {
                        Print("Trailling stop com falha. ResultRetcode", trade.ResultRetcode(), ", RetcodeDescription", trade.ResultRetcodeDescription());
                       }


                    }
                 }
           }
        }


     }
  }
//+------------------------------------------------------------------+
