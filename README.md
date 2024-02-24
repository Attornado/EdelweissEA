# EdelweissEA: A Hybrid Expert Advisor for MetaTrader 4 (in future with PyTorch-Powered FLF-LSTM Integration)

## Project Description:

### Compelling Introduction:
EdelweissEA is an educational trading bot that combines that incorporates a multi-indicator approach, including EMA, Stochastic/Awesome oscillators, ATR, ADX, Parabolic SAR, and Bollinger Bands, to enhance trading decisions. Dynamic risk management strategies based on ATR ensure optimized stop-loss and take-profit levels. In the plan to integrate the power of MetaTrader 4 integration with advanced machine learning techniques, specifically PyTorch-based FLF-LSTM models. This integration will allow for automated execution while leveraging sophisticated algorithms for future signal generation and strategy refinement.

### Target Audience:
EdelweissEA is designed for algorithmic trading students aiming to experiment with MetaTrader 4 users, and machine learning practitioners/students interested in finance who seek to leverage advanced technologies for automated trading strategies.

### Key Features:
- **Indicator Expertise:** Incorporates diverse trend indicators and their combination according to best practices.
- **Risk Management Focus:** Implements ATR-based dynamic stop-loss and take-profit.
- **Customization Flexibility:** Allows configuration for different market conditions and user preferences.
- **Future Integration:** Planned integration of FLF-LSTM model for enhanced predictive, data-driven capabilities to optimize trading strategies.

## Installation and Usage:

### Prerequisites:
- MetaTrader 4
- Python
- PyTorch 2.0+
- MatplotLib 

### Installation Steps:
1. Set up MetaTrader 4 on your system.
2. Install Python and required libraries.
3. Clone the repository.
4. Follow specific instructions for EA installation.

### Usage Guide:
1. Load the EA onto MetaTrader 4 by copying the EdelweissExpert.mq4 (usually under the <MetaTraderDir>/Experts/.
2. Configure settings according to your preferences.
3. Run the EA on the strategy tester.
4. For the FLF-LSTM, you can simply run the notebook file, as it is self-contained.

### Troubleshooting:
- N/A

## Technical Details:

### Architecture:
- Overview of data flow, indicator interaction, and decision-making processes.

### Indicators:
- Exponential Moving Average (EMA): A type of moving average that gives more weight to recent prices and reacts faster to price changes. It is calculated by multiplying the current price by a smoothing factor and adding it to the previous EMA value. The smoothing factor is calculated as: $$\alpha = \frac{2}{n + 1}$$ where $n$ is the period of the EMA. The formula for the EMA is: $$EMA_t = \alpha \times P_t + (1 - \alpha) \times EMA_{t-1}$$ where $EMA_t$ is the EMA value at time $t$, $P_t$ is the price at time $t$, and $EMA_{t-1}$ is the previous EMA value.

- Stochastic Oscillator: A momentum indicator that measures the position of the current price relative to its high-low range over a given period of time. It consists of two lines: the %K line and the %D line. The %K line is the fast line that shows the current position of the price relative to the high-low range. The %D line is the slow line that shows the smoothed average of the %K line. The formula for the %K line is: $$\%K = \frac{C_t - L_n}{H_n - L_n} \times 100$$ where $C_t$ is the current closing price, $L_n$ is the lowest price of the last $n$ periods, and $H_n$ is the highest price of the last $n$ periods. The formula for the %D line is: $$\%D = SMA(\%K, m)$$ where $SMA(\%K, m)$ is the simple moving average of the %K line over $m$ periods.

- Awesome Oscillator (AO): A momentum indicator that measures the difference between a fast and a slow moving average of the median price. The median price is calculated as the average of the high and low prices of each period. The formula for the AO is: $$AO = SMA(MP, f) - SMA(MP, s)$$ where $SMA(MP, f)$ is the simple moving average of the median price over $f$ periods, $SMA(MP, s)$ is the simple moving average of the median price over $s$ periods, and $f < s$.

- Average True Range (ATR): A volatility indicator that measures the average range of price movements over a given period of time. It is based on the true range, which is the greatest of the following: the current high minus the current low, the absolute value of the current high minus the previous close, or the absolute value of the current low minus the previous close. The formula for the ATR is: $$ATR = \frac{1}{n} \sum_{i=1}^n TR_i$$ where $n$ is the period of the ATR, and $TR_i$ is the true range of the $i$-th period.

- Average Directional Index (ADX): A trend strength indicator that measures the degree of directional movement in the market. It is based on the directional movement indicators, which are the plus directional indicator (+DI) and the minus directional indicator (-DI). The +DI measures the strength of the upward movement, while the -DI measures the strength of the downward movement. The formula for the ADX is: $$ADX = 100 \times SMA\left(\frac{|+DI - -DI|}{+DI + -DI}, n\right)$$ where $SMA(x, n)$ is the simple moving average of $x$ over $n$ periods. To calculate +DI and -DI, one needs price data consisting of high, low, and closing prices each period (typically each day). One first calculates the directional movement (+DM and -DM):

  $$\begin{aligned}
  &\text{UpMove} = \text{today's high} - \text{yesterday's high}\\
  &\text{DownMove} = \text{yesterday's low} - \text{today's low}\\
  &\text{if UpMove} > \text{DownMove and UpMove} > 0, \text{then +DM} = \text{UpMove, else +DM} = 0\\
  &\text{if DownMove} > \text{UpMove and DownMove} > 0, \text{then -DM} = \text{DownMove, else -DM} = 0\\
  \end{aligned}$$

  Then, +DI and -DI are:

  $$\begin{aligned}
  &+DI = 100 \times \frac{SMA(+DM, n)}{ATR}\\
  &-DI = 100 \times \frac{SMA(-DM, n)}{ATR}\\
  \end{aligned}$$
  
  where $SMA(+DM, n)$ and $SMA(-DM, n)$ are the simple moving averages of +DM and -DM over $n$ periods, and $ATR$ is the average true range, which is a measure of volatility.

- Parabolic SAR (PSAR): A trend-following indicator that shows the direction and potential reversal points of the market. It is represented by a series of dots that are placed either above or below the price, depending on the trend direction. The formula for the PSAR is: $$PSAR_t = PSAR_{t-1} + AF \times (EP - PSAR_{t-1})$$ where $PSAR_t$ is the PSAR value at time $t$, $PSAR_{t-1}$ is the previous PSAR value, $AF$ is the acceleration factor, and $EP$ is the extreme point. The acceleration factor is a variable that increases by a step (usually 0.02) every time a new extreme point is reached, up to a maximum value (usually 0.2). The extreme point is the highest high or the lowest low of the current trend. The PSAR switches from above to below the price or vice versa when the price crosses the PSAR value.

- Bollinger Bands: A volatility indicator that consists of three lines: the middle line, which is a simple moving average of the price, and the upper and lower bands, which are derived from the standard deviation of the price. The formula for the Bollinger Bands is: $$Middle = SMA(P, n)$$ $$Upper = Middle + k \times SD(P, n)$$ $$Lower = Middle - k \times SD(P, n)$$ where $SMA(P, n)$ is the simple moving average of the price over $n$ periods, $SD(P, n)$ is the standard deviation of the price over $n$ periods, and $k$ is a constant that determines the width of the bands (usually 2).

### FLF-LSTM Integration (Future):
- We plan to empower the EdelweissEA using the FLF-LSTM forecasting framework, providing additional insights to enabling enhanced dynamic enter/exit signals.

## Disclaimer:
- **Risk Warning:** This code is intended for educational purposes only. Trading involves significant risk of loss. Users should exercise caution and implement proper risk management strategies. The creators of EdelweissEA are not liable for any financial losses incurred.

## Contributing:

### Contribution Guidelines:
- Feel free to report any bug and contribute to the repository by opening a pull request ^^

### License:
- Distributed under [MIT License](https://opensource.org/licenses/MIT).

## Additional Considerations:

- **Clarity and Concision:** Ensure the readme is well-structured and uses clear language.
- **Visual Appeal:** Consider incorporating images, diagrams, or code snippets.
- **Community Engagement:** Encourage feedback and contributions via GitHub issues and discussion forums.
