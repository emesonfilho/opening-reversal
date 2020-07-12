# opening reversal
Trade system released by the channel  Outspoken Market: https://www.youtube.com/watch?v=tR4X9uM7QLA&t=343s

Leandro's blog post: https://www.outspokenmarket.com/blog

The strategy consists of:

* If the previous candle is bearish, and the current one goes up breaking the previous day's opening, buy at disruption.

* If the previous candle is bullish, and the current one falls breaking the previous day’s opening, selling on disruption.

![image](https://user-images.githubusercontent.com/48841448/87090850-099fff80-c20f-11ea-881e-4ca2277b99fb.png)

The results of the simulations with the above parameters were as follows:

![image](https://user-images.githubusercontent.com/48841448/87090976-410eac00-c20f-11ea-80ce-7ec462b7a546.png)

Tipo de ordem:

* ORDER_FILLING_FOK = If you have 10 contracts, he will only execute the order if he can get the 10 contracts.

* ORDER_FILLING_IOC = If you have 10 contracts and can only buy 5, you buy the 5.

* ORDER_FILLING_RETURN = If you have 10 contracts and you can only buy 5, you buy the 5 and so you can buy the other 5.

Desvio máximo de pontos de entrada: If the order has to be shipped in 100, it will still be executed 5 points above or below.

Pontos gatilho: Adds the number entered to the current market value, it is used if you want to advance or delay operations.

## Help Maintenance

I've been maintaining quite many repos these days and burning out slowly. If you could help me cheer up, buying me a cup of coffee will make my life really happy and get much energy out of it.

<a href="https://www.buymeacoffee.com/emesonfilho" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>

