# EdelweissEA: A Hybrid Expert Advisor for MetaTrader 4

## Table of Contents
- [EdelweissEA: A Hybrid Expert Advisor for MetaTrader 4 (in future with PyTorch-Powered FLF-LSTM Integration)](#edelweissea-a-hybrid-expert-advisor-for-metatrader-4-in-future-with-pytorch-powered-flf-lstm-integration)
  - [Project Description](#project-description)
    - [Compelling Introduction](#compelling-introduction)
    - [Target Audience](#target-audience)
    - [Key Features](#key-features)
  - [Installation and Usage](#installation-and-usage)
    - [Prerequisites](#prerequisites)
    - [Installation Steps](#installation-steps)
    - [Usage Guide](#usage-guide)
    - [Troubleshooting](#troubleshooting)
  - [Technical Details](#technical-details)
    - [Architecture](#architecture)
    - [Used Indicators](#used-indicators)
    - [Results](#results)
    - [FLF-LSTM Integration (Future)](#flf-lstm-integration-future)
  - [Disclaimer](#disclaimer)
  - [Contributing](#contributing)
    - [Contribution Guidelines](#contribution-guidelines)
    - [License](#license)

## Project Description

### Compelling Introduction
EdelweissEA is an educational trading bot that combines that incorporates a multi-indicator approach, including EMA, Stochastic/Awesome oscillators, ATR, ADX, Parabolic SAR, and Bollinger Bands, to enhance trading decisions. Dynamic risk management strategies based on ATR ensure optimized stop-loss and take-profit levels. In the plan to integrate the power of MetaTrader 4 integration with advanced machine learning techniques, specifically PyTorch-based [FLF-LSTM](https://www.sciencedirect.com/science/article/abs/pii/S1568494620307183) models. We provide a PyTorch implementation of this model. This integration will allow for automated execution while leveraging sophisticated algorithms for future signal generation and strategy refinement.

### Target Audience
EdelweissEA is designed for algorithmic trading students aiming to experiment with MetaTrader 4 users, and machine learning practitioners/students interested in finance who seek to leverage advanced technologies for automated trading strategies.

### Key Features
- **Indicator Expertise:** Incorporates diverse trend indicators and their combination according to best practices.
- **Risk Management Focus:** Implements ATR-based dynamic stop-loss and take-profit.
- **Customization Flexibility:** Allows configuration for different market conditions and user preferences.
- **Future Integration:** Planned integration of FLF-LSTM model for enhanced predictive, data-driven capabilities to optimize trading strategies.

## Installation and Usage

### Prerequisites
- MetaTrader 4
- Python
- PyTorch 2.0+
- MatplotLib 

### Installation Steps
1. Set up MetaTrader 4 on your system.
2. Install Python and required libraries.
3. Clone the repository.
4. Follow specific instructions for EA installation.

### Usage Guide
1. Load the EA onto MetaTrader 4 by copying the `Experts/EdelweissExpert.mq4` (usually under the `<MetaTraderDir>/MQL4/Experts/` directory).
2. Configure settings according to your preferences.
3. Run the EA on the strategy tester.
4. For [FLF-LSTM](https://www.sciencedirect.com/science/article/abs/pii/S1568494620307183) found in the `FLF-LSTM/` folder, you can simply run the notebook file changing the paths according to your needs, as it is self-contained.

### Troubleshooting
- N/A

## Technical Details

### Architecture
- Edelweiss Expert Advisor (EA) is a customizable automated trading system developed using MQL4 programming language for MetaTrader 4 platform. This EA employs various strategies and indicators to generate buy and sell signals based on user inputs and historical data analysis. Here is a summary of its main features:

1. **Operation Parameters**: These settings allow users to configure basic aspects such as trade lot sizes, allowed slippage, maximum risk per transaction, trailing stops, and default take profits and stop losses. Users can enable or disable optimization options and define specific behavior regarding opening and closing trades.

2. **Opening/Closing Parameters**: The `buy_signals_t` and `sell_signals_t` variables control how many consecutive signals must be detected before executing a corresponding buy or sell order. By setting these values greater than zero, traders can filter out potential noise and avoid unnecessary transactions.

3. **Technical Indicator Settings**: Various technical indicator configurations are available within the EA script. Some notable examples include moving averages, Average True Range (ATR), Stochastic Oscillator, Awesome Oscillator, and Bollinger Bands. Traders can fine-tune each individual indicator parameter to suit their preferences and desired trading style.

4. **Advanced Strategies**: In addition to traditional indicator combinations like MA crossing, the EA includes more complex strategies like identifying bullish and bearish saucers through Awesome Oscillator evaluation in combination with stochastic oscillator. Moreover, some components consider multiple timeframes simultaneously to provide better context when generating signals.

5. **Visualization & Logging Options**: Verbose logging allows developers and experienced traders to understand the decision-making process behind every generated signal and transaction execution. Furthermore, visual representation tools help identify trends and patterns directly within charts while monitoring real-time performance.

The primary goal of this EA appears to be providing flexibility and adaptability across different markets, assets, and trader requirements. It combines several popular technical indicators into advanced strategies tailored towards detecting profitable opportunities while minimizing risks associated with volatile financial instruments.

### Used Indicators
- **Exponential Moving Average (EMA)**: A type of moving average that gives more weight to recent prices and reacts faster to price changes. It is calculated by multiplying the current price by a smoothing factor and adding it to the previous EMA value. The formula for the EMA is: $$EMA_t = \alpha \times P_t + (1 - \alpha) \times EMA_{t-1}$$ where $EMA_t$ is the EMA value at time $t$, $P_t$ is the price at time $t$, $\alpha \in \left[0, 1 \right]$ is a smoothing factor, and $EMA_{t-1}$ is the previous EMA value.

- **Stochastic Oscillator**: A momentum indicator that measures the position of the current price relative to its high-low range over a given period of time. It consists of two lines: the %K line and the %D line. The %K line is the fast line that shows the current position of the price relative to the high-low range. The %D line is the slow line that shows the smoothed average of the %K line. The formula for the %K line is: $$\%K = \frac{C_t - L_n}{H_n - L_n} \times 100$$ where $C_t$ is the current closing price, $L_n$ is the lowest price of the last $n$ periods, and $H_n$ is the highest price of the last $n$ periods. The formula for the %D line is: $$\%D = SMA(\%K, m)$$ where $SMA(\%K, m)$ is the simple moving average of the %K line over $m$ periods.

- **Awesome Oscillator (AO)**: A momentum indicator that measures the difference between a fast and a slow moving average of the median price. The median price is calculated as the average of the high and low prices of each period. The formula for the AO is: $$AO = SMA(MP, f) - SMA(MP, s)$$ where $SMA(MP, f)$ is the simple moving average of the median price over $f$ periods, $SMA(MP, s)$ is the simple moving average of the median price over $s$ periods, and $f < s$.

- **Average True Range (ATR)**: A volatility indicator that measures the average range of price movements over a given period of time. It is based on the true range, which is the greatest of the following: the current high minus the current low, the absolute value of the current high minus the previous close, or the absolute value of the current low minus the previous close. The formula for the ATR is: $$ATR = SMA(TR_n, k)$$ where $n$ is the period of the ATR, $SMA( \cdot, k)$ is the $k$-period simple moving average, and $TR_n$ is the true range of the $n$-th period.

- **Average Directional Index (ADX)**: A trend strength indicator that measures the degree of directional movement in the market. It is based on the directional movement indicators, which are the plus directional indicator (+DI) and the minus directional indicator (-DI). The +DI measures the strength of the upward movement, while the -DI measures the strength of the downward movement. The formula for the ADX is: $$ADX = 100 \times SMA\left(\frac{|+DI - -DI|}{+DI + -DI}, n\right)$$ where $SMA(x, n)$ is the simple moving average of $x$ over $n$ periods. To calculate +DI and -DI, one needs price data consisting of high, low, and closing prices each period (typically each day). One first calculates the directional movement (+DM and -DM):

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

where $\tilde{SMA}(+DM, n)$ and $\tilde{SMA}(-DM, n)$ are the smoothed moving averages of +DM and -DM over $n$ periods, and $ATR$ is the average true range, which is a measure of volatility.

- **Parabolic SAR (PSAR)**: A trend-following indicator that shows the direction and potential reversal points of the market. It is represented by a series of dots that are placed either above or below the price, depending on the trend direction. The formula for the PSAR is: $$PSAR_t = PSAR_{t-1} + AF \times (EP - PSAR_{t-1})$$ where $PSAR_t$ is the PSAR value at time $t$, $PSAR_{t-1}$ is the previous PSAR value, $AF$ is the acceleration factor, and $EP$ is the extreme point. The acceleration factor is a variable that increases by a step (usually 0.02) every time a new extreme point is reached, up to a maximum value (usually 0.2). The extreme point is the highest high or the lowest low of the current trend. The PSAR switches from above to below the price or vice versa when the price crosses the PSAR value.

- **Bollinger Bands**: A volatility indicator that consists of three lines: the middle line, which is a simple moving average of the price, and the upper and lower bands, which are derived from the standard deviation of the price. The formula for the Bollinger Bands is: $$Middle = SMA(P, n)$$ $$Upper = Middle + k \times SD(P, n)$$ $$Lower = Middle - k \times SD(P, n)$$ where $SMA(P, n)$ is the simple moving average of the price over $n$ periods, $SD(P, n)$ is the standard deviation of the price over $n$ periods, and $k$ is a constant that determines the width of the bands (usually 2).

### Results
- We provide a folder (`OptimizationResults`) including all the results of appliying an genetic-algorithm-optimized EdelweissEA strategy to different timeframes (15 min, 30 min, 1 hour, daily) on EURUSD FTX historical data.

### FLF-LSTM Integration (Future)
- We plan to empower the EdelweissEA using the FLF-LSTM forecasting framework, providing additional insights to enabling enhanced dynamic enter/exit signals. Please refer to the original [FLF-LSTM](https://www.sciencedirect.com/science/article/abs/pii/S1568494620307183) paper for more information.

## Disclaimer
- **Risk Warning:** This code is intended for educational purposes only. Trading involves significant risk of loss. Users should exercise caution and implement proper risk management strategies. The creators of EdelweissEA are not liable for any financial losses incurred.

## Contributing

### Contribution Guidelines
- Feel free to report any bug and contribute to the repository by opening a pull request ^^

### License
- Distributed under [MIT License](https://opensource.org/licenses/MIT).
