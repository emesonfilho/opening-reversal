# opening reversal
Trade system released by the channel  Outspoken Market

The strategy consists of:

* If the previous candle is bearish, and the current one goes up breaking the previous day's opening, buy at disruption.

* If the previous candle is bullish, and the current one falls breaking the previous day’s opening, selling on disruption.

![image](https://user-images.githubusercontent.com/48841448/87036841-ce2b1400-c1c1-11ea-83a0-d59c316a5586.png)

Tipo de ordem:

* ORDER_FILLING_FOK = If you have 10 contracts, he will only execute the order if he can get the 10 contracts.

* ORDER_FILLING_IOC = If you have 10 contracts and can only buy 5, you buy the 5.

* ORDER_FILLING_RETURN = If you have 10 contracts and you can only buy 5, you buy the 5 and so you can buy the other 5.

Desvio máximo de pontos de entrada: If the order has to be shipped in 100, it will still be executed 5 points above or below.

Pontos gatilho: Adds the number entered to the current market value, it is used if you want to advance or delay operations.



