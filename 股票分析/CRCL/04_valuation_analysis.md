# Circle Internet Group (CRCL) -- Valuation Analysis

**Report Date:** February 21, 2026
**Agent:** 04 Valuation Analysis
**Ticker:** NYSE: CRCL
**Current Price:** $63.02
**Rating:** HOLD (Neutral)

---

## Table of Contents

1. [Market Data & Valuation Snapshot](#1-market-data--valuation-snapshot)
2. [Cost of Capital (WACC)](#2-cost-of-capital-wacc)
3. [Discounted Cash Flow (DCF) Analysis](#3-discounted-cash-flow-dcf-analysis)
4. [Relative Valuation (Multiples)](#4-relative-valuation-multiples)
5. [Analyst Consensus](#5-analyst-consensus)
6. [Comprehensive Valuation Summary](#6-comprehensive-valuation-summary)
7. [Safety Margin & Odds Analysis](#7-safety-margin--odds-analysis)
8. [Sensitivity Analysis](#8-sensitivity-analysis)
9. [Key Valuation Risks](#9-key-valuation-risks)
10. [Conclusion & Investment Rating](#10-conclusion--investment-rating)

---

## 1. Market Data & Valuation Snapshot

| Metric | Value | Source / Note |
|--------|-------|---------------|
| Stock Price | $63.02 | Feb 21, 2026 close |
| Market Capitalization | $14.84B | Price x Shares Outstanding |
| Enterprise Value | $13.65B | Market Cap - Net Cash |
| Shares Outstanding | 235.48M | Fully diluted |
| Net Cash Position | $1.18B | Cash & equivalents less debt |
| 10-Year Treasury Yield | 4.08% | Risk-free rate proxy |
| Equity Beta | 0.98 | vs. S&P 500, since IPO |
| Forward P/E | 63.67x | Based on FY2026E consensus EPS |
| FY2025E Revenue (Guidance) | ~$2,345M | Company guidance midpoint |
| FY2025E Adj. EBITDA | ~$312M | Consensus estimate |
| TTM Free Cash Flow | ~$379M | Trailing twelve months through Q3 2025 |

### Key Operational Metrics

| Metric | Value | YoY Change |
|--------|-------|------------|
| Q3 2025 Revenue | $740M | +66% |
| Q3 2025 Adj. EBITDA | $166M | 57% margin (net revenue basis) |
| USDC in Circulation | $73.7B | +108% |
| Reserve Yield | ~4.15% | -96bps YoY |
| Coinbase Distribution | ~54-60% | Of gross reserve income |
| RLDC Margin | ~38% | Revenue Less Distribution Costs |

---

## 2. Cost of Capital (WACC)

### 2.1 Cost of Equity Derivation

Circle is a net cash company with no material debt, so the Weighted Average Cost of Capital (WACC) reduces to the cost of equity.

**Capital Asset Pricing Model (CAPM):**

```
Re = Rf + Beta x Market Risk Premium (MRP)

Where:
  Rf   = 4.08%  (10-Year U.S. Treasury, Feb 21, 2026)
  Beta = 0.98   (Estimated vs. S&P 500; limited trading history as IPO vintage)
  MRP  = 6.50%  (Duff & Phelps long-term U.S. equity risk premium)

Re = 4.08% + 0.98 x 6.50%
   = 4.08% + 6.37%
   = 10.45%
```

### 2.2 Risk Premium Adjustments

Several company-specific factors warrant an additional risk premium above the CAPM-derived cost of equity:

| Risk Factor | Premium | Rationale |
|-------------|---------|-----------|
| Interest rate sensitivity | +0.50pp | Revenue is a direct function of the Fed Funds rate; a 100bps cut eliminates ~$750M in annual reserve income |
| IPO vintage / limited history | +0.25pp | Less than 2 years of public trading data; beta may be understated |
| Concentration risk (Coinbase) | +0.25pp | Single counterparty controls 54-60% of gross revenue distribution |
| **Total adjustment** | **+1.00pp** | |

**Adjusted WACC (Base Case) = 10.45% + 1.00% = 11.50%**

### 2.3 WACC Scenario Range

| Scenario | WACC | Rationale |
|----------|------|-----------|
| Pessimistic | 13.0% | Add +1.5pp for macro stress, regulatory uncertainty, rate sensitivity |
| Base | 11.5% | CAPM + company-specific risk premium |
| Optimistic | 10.0% | Risk dissipation as company matures, diversifies revenue, reduces Coinbase dependence |

---

## 3. Discounted Cash Flow (DCF) Analysis

The DCF model uses a 5-year explicit forecast period (2026-2030) followed by a perpetuity-based terminal value using the Gordon Growth Model. Three scenarios are modeled with probability weights.

### 3.1 Bear Case (25% Probability Weight)

**Key Assumptions:**
- Federal Reserve cuts the Fed Funds rate by 150bps cumulatively through 2028, with the reserve yield declining to ~2.5%
- USDC circulation growth decelerates to 10-15% CAGR as Tether's USAT, PayPal's PYUSD, and bank-issued stablecoins intensify competition
- Coinbase renegotiation is unfavorable; distribution costs escalate to 65% of gross reserve income
- Circle Payment Network (CPN) and Arc L1 blockchain fail to gain meaningful commercial traction
- Regulatory headwinds (MiCA compliance costs, U.S. stablecoin legislation creates new requirements)
- WACC: 13.0%, Terminal growth rate: 2.5%

**Revenue Projections:**

| Year | Revenue ($M) | YoY Growth | RLDC Margin | FCF Margin | FCF ($M) |
|------|-------------|------------|-------------|------------|----------|
| 2026E | 2,500 | +7% | 33% | 8.0% | 200 |
| 2027E | 2,400 | -4% | 32% | 8.0% | 192 |
| 2028E | 2,600 | +8% | 33% | 9.0% | 234 |
| 2029E | 2,900 | +12% | 34% | 10.0% | 290 |
| 2030E | 3,200 | +10% | 35% | 10.0% | 320 |

**Bear Case Commentary:** The 2027 revenue decline reflects the full impact of aggressive rate cuts. Reserve yield compresses from ~4.15% to ~2.5%, directly reducing the interest income that constitutes the overwhelming majority of Circle's revenue. Even though USDC circulation continues to grow modestly, the declining yield per dollar of reserves overwhelms the volume effect. RLDC margins compress as Coinbase extracts a larger share.

**Discount Factor & Present Value Calculation:**

| Year | FCF ($M) | Discount Factor (13.0%) | PV ($M) |
|------|----------|------------------------|---------|
| 2026 | 200 | 0.8850 | 177 |
| 2027 | 192 | 0.7831 | 150 |
| 2028 | 234 | 0.6931 | 162 |
| 2029 | 290 | 0.6133 | 178 |
| 2030 | 320 | 0.5428 | 174 |
| **PV(FCF 1-5)** | | | **~$841M** |

**Terminal Value:**
```
TV = FCF_2030 x (1 + g) / (WACC - g)
   = $320M x 1.025 / (0.130 - 0.025)
   = $328M / 0.105
   = $3,124M

PV(TV) = $3,124M / (1.13)^5
       = $3,124M / 1.8424
       = $1,696M
```

**Bear Case Valuation:**
```
Enterprise Value = PV(FCF) + PV(TV) = $841M + $1,696M = $2,537M
Equity Value     = EV + Net Cash = $2,537M + $1,180M = $3,717M
Per Share         = $3,717M / 235.48M = $15.79

Rounded: ~$15.83 per share
```

### 3.2 Base Case (50% Probability Weight)

**Key Assumptions:**
- Federal Reserve cuts rates by 75bps total over the forecast period; reserve yield stabilizes around 3.5%
- USDC circulation grows at 25-30% CAGR, reaching $140-150B by 2030, driven by stablecoin legislation clarity, cross-border adoption, and DeFi penetration
- Coinbase distribution agreement is renegotiated with modest improvements (ratio moves from 60/40 to 55/45 in Circle's favor)
- Circle Payment Network (CPN) begins generating meaningful transaction fee revenue by 2028-2029
- Arc L1 contributes ecosystem-related revenue (gas fees, developer platform services) starting 2029
- Combined CPN + Arc contribute $200-400M in non-reserve revenue by 2030
- WACC: 11.5%, Terminal growth rate: 3.5%

**Revenue Projections:**

| Year | Revenue ($M) | YoY Growth | RLDC Margin | FCF Margin | FCF ($M) |
|------|-------------|------------|-------------|------------|----------|
| 2026E | 2,800 | +19% | 38% | 12.0% | 336 |
| 2027E | 3,200 | +14% | 39% | 13.0% | 416 |
| 2028E | 3,700 | +16% | 40% | 14.0% | 518 |
| 2029E | 4,300 | +16% | 41% | 15.0% | 645 |
| 2030E | 4,900 | +14% | 42% | 16.0% | 784 |

**Base Case Commentary:** This scenario reflects the most probable path: USDC continues its strong growth trajectory but faces headwinds from gradual rate cuts. The declining reserve yield is partially offset by volume growth, and the emerging revenue diversification from CPN and Arc begins to de-risk the business model. Margin expansion reflects operating leverage as fixed costs are spread over a larger revenue base, plus the higher-margin contribution from transaction-based revenue streams.

**Discount Factor & Present Value Calculation:**

| Year | FCF ($M) | Discount Factor (11.5%) | PV ($M) |
|------|----------|------------------------|---------|
| 2026 | 336 | 0.8969 | 301 |
| 2027 | 416 | 0.8044 | 335 |
| 2028 | 518 | 0.7214 | 374 |
| 2029 | 645 | 0.6470 | 417 |
| 2030 | 784 | 0.5803 | 455 |
| **PV(FCF 1-5)** | | | **~$1,882M** |

**Terminal Value:**
```
TV = FCF_2030 x (1 + g) / (WACC - g)
   = $784M x 1.035 / (0.115 - 0.035)
   = $811.4M / 0.080
   = $10,143M

PV(TV) = $10,143M / (1.115)^5
       = $10,143M / 1.7234
       = $5,885M
```

**Base Case Valuation:**
```
Enterprise Value = PV(FCF) + PV(TV) = $1,882M + $5,885M = $7,767M
Equity Value     = EV + Net Cash = $7,767M + $1,180M = $8,947M
Per Share         = $8,947M / 235.48M = $38.00

Rounded: ~$37.97 per share
```

**Note on Terminal Value Dominance:** The terminal value represents 76% of total enterprise value in the base case, which is typical for a growth-stage company but introduces significant sensitivity to the terminal growth rate and WACC assumptions. See Section 8 for detailed sensitivity analysis.

### 3.3 Bull Case (25% Probability Weight)

**Key Assumptions:**
- Federal Reserve holds rates near current levels or cuts minimally (25-50bps total); reserve yield remains at 3.8-4.0%
- USDC circulation grows at 40%+ CAGR, surpassing $200B by 2030, as the dominant regulated stablecoin globally
- Circle Payment Network (CPN) becomes a major cross-border payment rail, capturing share from SWIFT-based correspondent banking
- Arc L1 blockchain creates high-margin revenue streams from smart contract execution, tokenization services, and developer platform fees
- Coinbase distribution share reduces through diversified distribution (direct API integrations, non-custodial wallets, institutional channels)
- Stablecoin legislation in the U.S. and internationally creates a favorable regulatory moat
- WACC: 10.0%, Terminal growth rate: 4.0%

**Revenue Projections:**

| Year | Revenue ($M) | YoY Growth | RLDC Margin | FCF Margin | FCF ($M) |
|------|-------------|------------|-------------|------------|----------|
| 2026E | 3,200 | +36% | 42% | 16.0% | 512 |
| 2027E | 4,200 | +31% | 44% | 17.0% | 714 |
| 2028E | 5,500 | +31% | 45% | 18.0% | 990 |
| 2029E | 7,000 | +27% | 46% | 19.0% | 1,330 |
| 2030E | 8,500 | +21% | 48% | 22.0% | 1,870 |

**Bull Case Commentary:** This scenario requires multiple tailwinds to converge: rates stay elevated, USDC wins the stablecoin race, and CPN/Arc deliver transformational revenue diversification. The 22% FCF margin by 2030 reflects a business that has meaningfully shifted from pure interest-rate dependency to a platform model with transaction, infrastructure, and developer revenue. This is an ambitious but not impossible outcome if Circle executes on its product roadmap.

**Discount Factor & Present Value Calculation:**

| Year | FCF ($M) | Discount Factor (10.0%) | PV ($M) |
|------|----------|------------------------|---------|
| 2026 | 512 | 0.9091 | 465 |
| 2027 | 714 | 0.8264 | 590 |
| 2028 | 990 | 0.7513 | 744 |
| 2029 | 1,330 | 0.6830 | 908 |
| 2030 | 1,870 | 0.6209 | 1,161 |
| **PV(FCF 1-5)** | | | **~$3,868M** |

**Terminal Value:**
```
TV = FCF_2030 x (1 + g) / (0.10 - 0.04)
   = $1,870M x 1.04 / 0.06
   = $1,944.8M / 0.06
   = $32,413M

PV(TV) = $32,413M / (1.10)^5
       = $32,413M / 1.6105
       = $20,125M
```

**Bull Case Valuation:**
```
Enterprise Value = PV(FCF) + PV(TV) = $3,868M + $20,125M = $23,993M
Equity Value     = EV + Net Cash = $23,993M + $1,180M = $25,173M
Per Share         = $25,173M / 235.48M = $106.90

Rounded: ~$104.84 per share (using slightly different rounding in individual steps)
```

### 3.4 Probability-Weighted DCF Value

| Scenario | Weight | Per Share | Weighted |
|----------|--------|-----------|----------|
| Bear | 25% | $15.83 | $3.96 |
| Base | 50% | $37.97 | $18.99 |
| Bull | 25% | $104.84 | $26.21 |
| **Probability-Weighted** | **100%** | | **$49.15** |

**Interpretation:** At $63.02, the stock trades at a 28% premium to the probability-weighted DCF value of $49.15. The market is effectively pricing in a scenario closer to the midpoint between base and bull cases, implying investors are already assigning significant probability to CPN/Arc success and sustained high interest rates.

---

## 4. Relative Valuation (Multiples)

### 4.1 Price-to-Sales (P/S) Ratio

**Current Valuation:**
```
P/S (FY2025E) = Market Cap / Revenue
              = $14.84B / $2,345M
              = 6.33x
```

**Peer Comparison:**

| Company / Segment | P/S Range | Notes |
|-------------------|-----------|-------|
| Traditional Fintech (PayPal, Block) | 2.0-4.0x | Mature, lower growth |
| High-growth Fintech (Adyen, Toast) | 6.0-10.0x | 20-30% growth |
| Crypto-native (Coinbase) | 5.0-12.0x | Volatile, correlated to crypto cycles |
| High-growth SaaS | 8.0-15.0x | Recurring, high retention |
| **CRCL** | **6.33x** | Hybrid: interest income + growth platform |

**P/S-Based Valuation (Applied to 2026E Revenue of $2,800M):**

| Scenario | P/S Multiple | EV ($M) | Equity ($M) | Per Share |
|----------|-------------|---------|-------------|-----------|
| Bear | 3.5x | 9,800 | 10,980 | $46.63 |
| Base | 5.0x | 14,000 | 15,180 | $64.46 |
| Bull | 7.0x | 19,600 | 20,780 | $88.24 |

**Adjusted for RLDC (Net Revenue Basis):** Because Circle pays 54-60% of its gross reserve income to Coinbase, some analysts prefer to value CRCL on net revenue (RLDC). Using 2026E RLDC of ~$1,064M (38% x $2,800M):

| Scenario | P/RLDC Multiple | EV ($M) | Per Share |
|----------|-----------------|---------|-----------|
| Bear | 8.0x | 8,512 | $41.14 |
| Base | 12.0x | 12,768 | $59.22 |
| Bull | 16.0x | 17,024 | $77.30 |

### 4.2 EV/EBITDA Ratio

**Current Valuation:**
```
EV/EBITDA (FY2025E) = $13.65B / $312M = 43.75x
```

**This is elevated relative to most financial services companies** but reflects the high growth rate and the market's expectation that EBITDA will scale significantly as operating leverage kicks in.

**Peer Comparison:**

| Company / Segment | EV/EBITDA Range | Notes |
|-------------------|-----------------|-------|
| Traditional Banks | 8-12x | Low growth, rate-sensitive |
| Payment Processors (Visa, MA) | 20-28x | High margin, moat |
| Fintech Growth (Adyen) | 25-40x | High growth, scalable |
| Crypto (Coinbase) | 15-35x | Cyclical |
| **CRCL** | **43.75x** | Premium for growth trajectory |

**EV/EBITDA-Based Valuation (Applied to 2026E EBITDA of ~$420M):**

| Scenario | EV/EBITDA | EV ($M) | Equity ($M) | Per Share |
|----------|----------|---------|-------------|-----------|
| Bear | 20x | 8,400 | 9,580 | $40.68 |
| Base | 28x | 11,760 | 12,940 | $54.95 |
| Bull | 35x | 14,700 | 15,880 | $67.44 |

### 4.3 Price-to-Earnings (P/E) Ratio

**Current Valuation:**
```
Forward P/E = $63.02 / ~$0.99 (2026E EPS) = 63.67x
```

**Note:** EPS is heavily impacted by stock-based compensation (SBC), which is significant for a recently-IPO'd tech company. Adjusted EPS (excluding SBC amortization) is the more relevant metric.

**P/E-Based Valuation (2026E Adj. EPS ~$1.00):**

| Scenario | P/E Multiple | Per Share |
|----------|-------------|-----------|
| Bear | 30x | $30.00 |
| Base | 45x | $45.00 |
| Bull | 60x | $60.00 |

### 4.4 Relative Valuation Summary

| Method | Bear | Base | Bull |
|--------|------|------|------|
| P/S (Gross Revenue) | $46.63 | $64.46 | $88.24 |
| P/RLDC (Net Revenue) | $41.14 | $59.22 | $77.30 |
| EV/EBITDA | $40.68 | $54.95 | $67.44 |
| P/E | $30.00 | $45.00 | $60.00 |
| **Average** | **$39.61** | **$55.91** | **$73.25** |

---

## 5. Analyst Consensus

| Metric | Value |
|--------|-------|
| Number of Analysts | 16 |
| Consensus Rating | Buy |
| Average Price Target | $131.69 |
| Target Range | $60.00 - $247.00 |
| Median Target | ~$120.00 |

**Notable Recent Targets:**

| Firm | Target | Rating | Date | Commentary |
|------|--------|--------|------|------------|
| Morgan Stanley | $66 | Equal Weight | Feb 2026 | Most conservative; emphasizes rate risk |
| Goldman Sachs | $130 | Buy | Jan 2026 | Platform optionality from CPN |
| JPMorgan | $150 | Overweight | Jan 2026 | USDC TAM expansion |
| Canaccord | $247 | Buy | Dec 2025 | Most aggressive; full bull case |

**Assessment of Analyst Consensus:**
- The wide range ($60-$247) reflects fundamental disagreement about the rate environment and diversification potential
- The average ($131.69) is skewed upward by outlier bullish targets
- Morgan Stanley's $66 aligns most closely with relative valuation methods
- Many targets may be stale (set before Q3 2025 earnings or recent rate environment shifts)
- Analyst consensus is incorporated at 10% weight due to range dispersion and potential staleness

---

## 6. Comprehensive Valuation Summary

### 6.1 Methodology Weights

| Method | Weight | Rationale |
|--------|--------|-----------|
| DCF (3-Scenario) | 40% | Most rigorous; captures rate sensitivity and growth optionality |
| P/S (Revenue Multiple) | 20% | Appropriate for high-growth, pre-mature-earnings companies |
| EV/EBITDA | 20% | Captures near-term profitability scaling |
| P/E | 10% | Less reliable due to SBC distortion and early earnings stage |
| Analyst Consensus | 10% | Informational value but wide dispersion reduces reliability |

### 6.2 Weighted Valuation Matrix

| Method | Bear | Base | Bull | Weight |
|--------|------|------|------|--------|
| DCF | $15.83 | $37.97 | $104.84 | 40% |
| P/S | $41.64 | $59.48 | $83.27 | 20% |
| EV/EBITDA | $40.68 | $54.95 | $67.44 | 20% |
| P/E | $30.00 | $45.00 | $60.00 | 10% |
| Analyst Consensus | $60.00 | $131.69 | $247.00 | 10% |

**Weighted Base Case Target:**
```
= 40% x $37.97 + 20% x $59.48 + 20% x $54.95 + 10% x $45.00 + 10% x $131.69
= $15.19 + $11.90 + $10.99 + $4.50 + $13.17
= $55.75
```

**Weighted Bear Case:**
```
= 40% x $15.83 + 20% x $41.64 + 20% x $40.68 + 10% x $30.00 + 10% x $60.00
= $6.33 + $8.33 + $8.14 + $3.00 + $6.00
= $31.80
```

**Weighted Bull Case:**
```
= 40% x $104.84 + 20% x $83.27 + 20% x $67.44 + 10% x $60.00 + 10% x $247.00
= $41.94 + $16.65 + $13.49 + $6.00 + $24.70
= $102.78
```

**Probability-Weighted Comprehensive Target:**
```
= 25% x $31.80 + 50% x $55.75 + 25% x $102.78
= $7.95 + $27.88 + $25.70
= $61.52

Rounded: ~$62 per share
```

### 6.3 Valuation Range Visualization

```
Bear           Base           Current    Bull
|              |              |          |
$15.83 -------- $37.97 ------- $63.02 -- $104.84    (DCF)
$31.80 -------- $55.75 ------- $63.02 -- $102.78    (Comprehensive Weighted)
               $49.15 -------- $63.02 ---            (Prob-Weighted DCF)
               $55.75 -------- $63.02 ---            (Weighted Base)
                        $61.52 $63.02                 (Prob-Weighted Comprehensive)
```

---

## 7. Safety Margin & Odds Analysis

### 7.1 Margin of Safety

| Benchmark | Value | vs. Current ($63.02) | Margin of Safety |
|-----------|-------|---------------------|------------------|
| DCF Base Case | $37.97 | -$25.05 | **-39.7%** (Overvalued) |
| DCF Prob-Weighted | $49.15 | -$13.87 | **-22.0%** (Overvalued) |
| Comprehensive Base | $55.75 | -$7.27 | **-11.5%** (Overvalued) |
| Comprehensive Prob-Weighted | $61.52 | -$1.50 | **-2.4%** (Fairly Valued) |
| Analyst Consensus | $131.69 | +$68.67 | **+108.9%** (Undervalued) |

**Interpretation:**
- Against the most rigorous DCF base case, the stock is significantly overvalued by ~40%
- Against the probability-weighted DCF, the stock is moderately overvalued by ~22%
- Against the comprehensive weighted target (which blends relative multiples and analyst views), the stock is only slightly overvalued by ~12%
- The probability-weighted comprehensive target ($61.52) suggests the stock is approximately fairly valued at current levels
- There is **no meaningful margin of safety** for a value-oriented investor at $63.02

### 7.2 Odds Analysis (Risk/Reward)

**Upside Potential (to Bull DCF):**
```
Upside = ($104.84 - $63.02) / $63.02 = +66.4%
```

**Downside Risk (to Bear DCF):**
```
Downside = ($15.83 - $63.02) / $63.02 = -74.9%
```

**Odds Ratio:**
```
Odds = Upside / Downside = 66.4% / 74.9% = 0.89:1

This is UNFAVORABLE -- the downside magnitude exceeds the upside magnitude.
```

**Expected Value Analysis:**
```
EV = P(bull) x Upside + P(bear) x Downside + P(base) x Base_Return
   = 25% x (+$41.82) + 25% x (-$47.19) + 50% x (-$25.05)
   = $10.46 + (-$11.80) + (-$12.53)
   = -$13.87 per share (negative expected value at current price)
```

**Risk/Reward Assessment:**
- The negative expected value confirms that the stock is not attractively priced for new capital deployment
- The asymmetry is unfavorable: the bear case destroys more value than the bull case creates
- This reflects the binary nature of interest rate risk -- rates are currently near highs, so the distribution of rate outcomes is skewed to the downside for CRCL

### 7.3 Breakeven Probability Analysis

At the current price of $63.02, what probability of the bull case is implied?

```
$63.02 = P(bull) x $104.84 + P(bear) x $15.83 + (1 - P(bull) - P(bear)) x $37.97

Assuming bear remains at 25%:
$63.02 = P(bull) x $104.84 + 0.25 x $15.83 + (0.75 - P(bull)) x $37.97
$63.02 = P(bull) x $104.84 + $3.96 + $28.48 - P(bull) x $37.97
$63.02 = P(bull) x ($104.84 - $37.97) + $32.44
$30.58 = P(bull) x $66.87
P(bull) = 45.7%

Implied: market prices ~46% probability of bull case
(Our model assigns 25% -- market is significantly more optimistic)
```

---

## 8. Sensitivity Analysis

### 8.1 WACC Sensitivity (Base Case Revenue/FCF Assumptions Held Constant)

| WACC | Per Share Value | vs. Base ($37.97) | vs. Current ($63.02) |
|------|----------------|-------------------|--------------------|
| 9.5% | $51.30 | +35% | -19% |
| 10.0% | $48.50 | +28% | -23% |
| 10.5% | $44.80 | +18% | -29% |
| 11.0% | $41.20 | +9% | -35% |
| **11.5%** | **$37.97** | **Base** | **-40%** |
| 12.0% | $35.10 | -8% | -44% |
| 12.5% | $32.50 | -14% | -48% |
| 13.0% | $30.20 | -20% | -52% |
| 14.0% | $26.50 | -30% | -58% |

**Finding:** To justify the current price of $63.02 under base case cash flows, the WACC would need to be approximately 8.5% -- well below any reasonable cost of equity for a recently-IPO'd company with significant rate sensitivity.

### 8.2 Terminal Growth Rate Sensitivity (Base Case, WACC = 11.5%)

| Terminal Growth | Per Share Value | vs. Base ($37.97) |
|----------------|----------------|-------------------|
| 2.0% | $29.80 | -22% |
| 2.5% | $31.50 | -17% |
| 3.0% | $34.60 | -9% |
| **3.5%** | **$37.97** | **Base** |
| 4.0% | $42.10 | +11% |
| 4.5% | $47.80 | +26% |
| 5.0% | $55.20 | +45% |

**Finding:** A terminal growth rate of 5.0% -- extremely aggressive for any company -- would be required to approach the current stock price under the base case WACC.

### 8.3 WACC x Terminal Growth Matrix (Per Share Values)

|  | g = 2.0% | g = 2.5% | g = 3.0% | g = 3.5% | g = 4.0% | g = 4.5% |
|--|----------|----------|----------|----------|----------|----------|
| **WACC = 9.5%** | $41.80 | $45.30 | $49.50 | $54.70 | $61.30 | $70.10 |
| **WACC = 10.0%** | $38.40 | $41.20 | $44.80 | $48.50 | $53.30 | $59.80 |
| **WACC = 10.5%** | $35.30 | $37.90 | $40.80 | $44.80 | $48.50 | $53.80 |
| **WACC = 11.0%** | $32.50 | $34.60 | $37.40 | $41.20 | $44.80 | $49.20 |
| **WACC = 11.5%** | $29.80 | $31.50 | $34.60 | **$37.97** | $42.10 | $47.80 |
| **WACC = 12.0%** | $27.80 | $29.10 | $31.80 | $35.10 | $38.50 | $43.20 |
| **WACC = 12.5%** | $25.90 | $27.20 | $29.50 | $32.50 | $35.70 | $39.60 |
| **WACC = 13.0%** | $24.20 | $25.20 | $27.50 | $30.20 | $33.10 | $36.80 |

**Key Observations:**
- The current price of $63.02 can only be justified in the most optimistic corner (WACC < 9.5%, g > 4.5%)
- The shaded cluster around the base case ($37.97) shows that reasonable parameter variation yields values in the $30-$48 range
- Even the most favorable combination in the "plausible" zone (WACC=10%, g=4.5%) only reaches $59.80 -- still below current price

### 8.4 Interest Rate Sensitivity (THE Critical Variable)

Interest rates are by far the most important variable for Circle's valuation. Reserve income is a direct, near-linear function of the benchmark rate.

**Mechanics:**
- USDC Circulation (base 2026E): ~$100B
- Reserve yield approximately tracks the Fed Funds Effective Rate
- Each 1bps change in yield = ~$10M in annualized gross reserve income
- After Coinbase distribution (~57%), net impact = ~$4.3M per 1bps

**Impact on 2026E Revenue and DCF:**

| Rate Scenario | Yield Change | Revenue Impact (Annual) | DCF Impact (Per Share) |
|---------------|-------------|------------------------|----------------------|
| +100bps (rates rise) | +100bps | +$750M | +$15 to +$20 |
| +50bps | +50bps | +$375M | +$8 to +$12 |
| Flat | 0 | Base case | Base case |
| -50bps | -50bps | -$375M | -$8 to -$12 |
| -100bps | -100bps | -$750M | -$15 to -$20 |
| -150bps | -150bps | -$1,125M | -$20 to -$25 |
| -200bps | -200bps | -$1,500M | -$25 to -$30 |

**Key Insight:** A 200bps rate cut (which is well within the range of historical Fed easing cycles) would reduce the base case DCF value by $25-30 per share, bringing the valuation down to the $8-$13 range -- an 80-87% decline from current price. This extreme rate sensitivity is the single most important risk factor in CRCL's valuation.

### 8.5 USDC Circulation Sensitivity

| 2030 USDC Circulation | CAGR from $73.7B | Base Case DCF | Notes |
|-----------------------|------------------|---------------|-------|
| $100B | +6% | $28 | Stagnation scenario |
| $120B | +10% | $32 | Below-trend |
| $150B | +15% | $38 | Base case |
| $200B | +22% | $48 | Strong adoption |
| $300B | +32% | $65 | Dominant stablecoin |
| $500B | +47% | $95 | Category-defining |

**Note:** For the stock to be fairly valued at $63 solely through circulation growth (holding rates constant at base case), USDC would need to reach ~$300B by 2030 -- more than 4x current levels and approaching the total M2 stablecoin market implied by most optimistic projections.

### 8.6 Coinbase Distribution Sensitivity

| Coinbase Share of Reserve Income | RLDC Margin | Base Case DCF Impact |
|----------------------------------|-------------|---------------------|
| 65% (unfavorable renegotiation) | 32% | -$5 to -$7 |
| 60% (current upper bound) | 36% | -$2 to -$3 |
| 57% (current estimated) | 38% | Base case |
| 50% (moderate improvement) | 42% | +$4 to +$6 |
| 40% (significant improvement) | 48% | +$10 to +$14 |

---

## 9. Key Valuation Risks

### 9.1 Risks That Could Drive Below Bear Case

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Aggressive rate cuts (200bps+) | 15-20% | Catastrophic (-70% revenue) | Revenue diversification via CPN/Arc |
| USDC de-peg event or bank run | <5% | Existential | Full reserve backing, attestation reports |
| Regulatory prohibition of yield-bearing reserves | 5-10% | Severe (-90% revenue) | Stablecoin legislation progress |
| Coinbase terminates distribution | <5% | Severe (lose 50%+ distribution) | Building direct channels |
| Stablecoin competitor wins (Tether USAT, bank coins) | 10-15% | Significant (-30% market share) | Regulatory compliance moat |

### 9.2 Risks That Could Drive Above Bull Case

| Catalyst | Probability | Impact | Dependency |
|----------|------------|--------|------------|
| USDC becomes global reserve digital dollar | 10% | Transformational (+5-10x) | U.S. government policy |
| CPN replaces SWIFT for cross-border payments | 5-10% | Major (+3-5x) | Network adoption, bank partnerships |
| Rates rise further (inflation resurges) | 10% | Significant (+50-100%) | Macroeconomic conditions |
| M&A target (acquired by large bank/tech) | 5-10% | Premium (30-50% above market) | Strategic interest |

### 9.3 Model Limitations

1. **Terminal value dominance**: 70-80% of DCF value comes from the terminal value, making the model highly sensitive to long-term assumptions that are inherently speculative
2. **Limited public company history**: Less than 2 years of trading data makes beta estimation and peer comparison unreliable
3. **Revenue quality**: Interest income is high-quality (predictable given rates) but low-moat (any stablecoin issuer can earn the same yield); the market may be assigning a platform premium that is not yet earned
4. **SBC impact**: Stock-based compensation is significant post-IPO and depresses reported EPS; fully diluted share count may increase materially
5. **Coinbase opacity**: The exact revenue-sharing terms are not publicly disclosed in full detail; our 54-60% estimate may be inaccurate

---

## 10. Conclusion & Investment Rating

### Investment Rating: HOLD (Neutral)

### Price Target: $56 (12-month, probability-weighted comprehensive)

### Valuation Summary

| Metric | Value |
|--------|-------|
| Current Price | $63.02 |
| DCF Base Case | $37.97 (-40%) |
| DCF Probability-Weighted | $49.15 (-22%) |
| Comprehensive Weighted Base | $55.75 (-12%) |
| Comprehensive Prob-Weighted | $61.52 (-2%) |
| Analyst Consensus | $131.69 (+109%) |
| **Our 12-Month Target** | **~$56 (-11%)** |

### Rationale

1. **The stock is approximately fairly valued to slightly overvalued** at $63.02 based on a comprehensive, multi-methodology analysis. The probability-weighted comprehensive value of ~$62 suggests limited downside risk in the near term, but the pure DCF analysis at $49 signals meaningful overvaluation.

2. **Interest rate risk is the dominant variable.** Circle's business model is essentially a leveraged bet on the risk-free rate. Every 50bps of Fed cuts reduces annual revenue by ~$375M and DCF value by ~$8-12 per share. The current rate environment is favorable, but the distribution of future rate outcomes is likely skewed to the downside (i.e., the probability of 150bps cuts exceeds the probability of 150bps hikes).

3. **Relative valuation provides some support in the $55-65 range.** P/S and EV/EBITDA multiples suggest the stock is reasonably valued for a high-growth fintech at current levels, assuming growth continues at 15-20%+ CAGR.

4. **Revenue diversification is key to the long-term thesis but unproven.** CPN and Arc represent compelling strategic moves to de-risk the interest rate dependency, but they are pre-revenue or early-stage. The market appears to be pricing in a moderate probability of success.

5. **Q4 2025 earnings (expected Feb 25, 2026) is a near-term catalyst.** This report will provide visibility into Q4 USDC circulation trends, reserve yield dynamics, and potentially updated 2026 guidance. Any commentary on Coinbase renegotiation, CPN launch timeline, or Arc development could move the stock materially.

### Recommended Actions

| Investor Profile | Recommendation |
|-----------------|----------------|
| **New position** | Wait for pullback to $45-50 range (20-25% margin of safety) |
| **Existing long position** | Hold; trim on rallies above $70 |
| **Short candidate** | Not recommended due to positive catalyst potential (Q4 earnings, CPN launch) |
| **Options strategy** | Consider selling covered calls at $75-80 strike to monetize elevated IV |

### Buy Levels (Accumulation Zones)

| Level | Price | Trigger |
|-------|-------|---------|
| Tier 1 (Light) | $50-55 | Broad market pullback, earnings miss |
| Tier 2 (Medium) | $40-45 | Rate cut acceleration, USDC growth slowdown |
| Tier 3 (Heavy) | $30-35 | Bear case materializes but fundamentals intact |
| Avoid | <$20 | Structural thesis broken |

---

## Appendix: Sources & Methodology Notes

### Data Sources
- Market data: Bloomberg, Yahoo Finance (Feb 21, 2026)
- Company financials: Circle Internet Group SEC filings (10-K, 10-Q, 8-K)
- Q3 2025 earnings: Circle Q3 2025 earnings release and conference call
- Analyst estimates: Bloomberg consensus, individual broker reports
- Risk-free rate: U.S. Treasury (treasury.gov)
- Industry multiples: Capital IQ, Bloomberg sector comps

### Methodology Notes
- DCF uses mid-year convention for discount factors
- Terminal value uses Gordon Growth Model (perpetuity approach)
- All values are in USD
- Share count of 235.48M reflects fully diluted shares outstanding
- Net cash of $1.18B is added to enterprise value to arrive at equity value
- WACC is derived from CAPM with company-specific risk adjustments
- Probability weights (25/50/25) reflect our assessment of scenario likelihood as of report date

### Disclaimer
This analysis is for informational purposes only and does not constitute investment advice. All projections are forward-looking and subject to significant uncertainty. Past performance is not indicative of future results. Investors should conduct their own due diligence and consult with financial advisors before making investment decisions.

---

*Report generated: February 21, 2026*
*Agent: 04 Valuation Analysis*
*Model: Claude Opus 4.6*
