# ChainDraw-FairTicket
## Basic Function Introduction:
Let's start with the basic functionalities of our platform. First, let's talk about user login and the event organizer dashboard:

Users log into the platform using a crypto wallet to perform subsequent operations.
Event organizers can log in and create concert information on the dashboard. After submitting the details, they wait for platform approval. Once approved, the organizer can choose to publish the concert. The platform will call on-chain smart contracts to create a lottery pool, opening up ticket subscription.
## Current Issues:
Next, let's address the current issues in the ticketing system:

Ticket Price Speculation and Black Market Trading: In Web2 systems, once tickets are sold, they are often resold at high prices in secondary markets, distorting the original fairness of the ticket market.
Regional Discrimination: Traditional ticketing platforms may set different winning probabilities or empty pools for specific regions, causing some users to never win, leading to claims of unfairness.
Lack of Verifiability in the Lottery Process: In a Web2 environment, lottery mechanisms are often black-box operations, making it impossible for users to verify the authenticity and fairness of the lottery.
## Solutions Provided by ChainDraw:
To tackle these issues, ChainDraw offers the following solutions:

### Addressing Regional Issues and Lack of Verifiability in the Lottery Process:
We ensure lottery transparency through several methods:

Factory Pattern for Lottery Contracts: 
    By utilizing the factory pattern, we build lottery contracts that establish a one-to-one relationship between concert ticket types and pools. On-chain contracts are open-source and parameter-transparent, increasing lottery transparency. Deploying smart contracts on the blockchain ensures all lottery rules and pool allocations are globally unified, with every change and lottery result recorded on-chain and publicly accessible. This way, users from any region have the same winning probability, and every step can be audited by anyone.
Chainlink VRF Technology: 
    Using Chainlink's Verifiable Random Function (VRF), we provide a completely transparent and verifiable random number generation mechanism for the lottery. Each draw is backed by verifiable on-chain evidence ensuring randomness and fairness, allowing all users to participate fairly regardless of their region. The system requires users to pay LINK token fees associated with using VRF, ensuring the platform leverages advanced blockchain technology and security without additional burden. Combining Chainlink's VRF technology with blockchain transparency brings verifiability and globally unified lottery opportunities to the system.
Global Execution of Smart Contracts: 
    Managing pools decentrally using smart contracts ensures that users from all regions can see the same pool information, eliminating regional bias. Every fund movement recorded on-chain is public and transparent, enhancing system trust.
User Identity Verification: 
    Implementing NFT binding to user information ensures "one person, one ticket," achieving dual verification:
    Users prove ownership of the event's NFT.
    Users prove the identity information bound to the NFT is their own.

### Addressing Ticket Price Speculation and Black Market Trading:
Let's explore how we address the issue of ticket price speculation and black market trading:

Lack of Effective Regulation and Transparent Market Mechanisms:
     In the absence of official oversight, tickets are often resold at higher than face value prices in secondary markets, leading to artificial inflation of ticket prices.
Lack of Transparency: 
    The source and flow of tickets are often unclear, making it difficult for regulatory bodies to track and intervene in unfair transactions. Black market traders exploit this gap, hoarding and reselling tickets for high profits, while ordinary consumers face unfair treatment and economic losses.
Zero Cost for Lottery Participation: 
    Creating accounts at no cost increases the probability of winning, leading to ticket hoarding and secondary market disruption.
We address these issues by leveraging blockchain characteristics and contract automation to achieve strict market oversight and transaction transparency in a way that is difficult to implement in Web2. 

Our solutions include:
    NFT Transfer Restriction: 
        By rewriting the ERC721 _transfer function, we implement transfer restrictions. Before the concert ends, users can only sell or buy tickets via the market contract. After the concert ends, users can freely transfer their NFT tickets.
    Sale Restriction: 
        The sale price is controlled based on the concert's status. Before the concert ends, the sale price cannot exceed the original price (the deposit paid during the lottery). After the concert ends, there are no price restrictions.
    Submitting Collateral to Participate in the Lottery: 
        Inspired by BTC's 51% attack concept, users submit collateral equivalent to the ticket price when participating in the lottery. This makes the cost of malicious registration outweigh the benefits, preventing bulk registration and speculation.
### How We Profit:
Now, let's discuss how our system generates revenue. Our primary revenue model is through transaction fees charged on each successful ticket transaction. As the platform's transaction volume increases, this fee-based model provides stable and sustainable revenue growth.

### Future Outlook:
Finally, let's look at our future plans. Our vision includes abstracting ChainDraw's functionality to support any fair lottery event, not just concerts. We are also exploring dynamic pricing models, loyalty rewards for frequent customers, and enhanced analytics for event organizers.

## 项目介绍
ChainDraw 是一个去中心化的演唱会门票抽选系统，旨在提供一个公平、透明的门票分配平台。我们利用区块链技术和Chainlink的VRF（可验证随机函数）来确保抽选过程的公正性和不可预测性。此项目不仅增加了演唱会门票销售的透明度，还有效防止了黄牛和恶意大量注册问题。

## 主要特性
- **去中心化**：完全在区块链上运行，确保所有交易和抽选过程的透明性。
- **公平性抽选**：利用Chainlink VRF生成随机数，确保每次抽选的公正性。
- **抗女巫攻击**：通过KYC验证和抵押系统，有效预防重复注册和女巫攻击。
- **NFT门票**：中奖者将收到特定的NFT，作为门票使用，并包含唯一的身份验证信息。
- **门票抵押**：：要求用户在报名时缴纳一定数额的押金或抵押品（如ETH或其他代币）。抵押品将在未中奖时返还，这可以大幅提高恶意注册的成本。

## 系统功能
报名系统：用户通过链接他们的钱包进行报名，提交必要的信息如联系方式和支付门票的意向金（如果需要）。
抽选过程：在报名结束后，智能合约利用Chainlink VRF产生随机数，根据这个随机数决定中奖者。
票务发放：中奖者将收到NFT（非同质化代币）作为门票，NFT内嵌了用户的身份验证信息和票据详情。
二手市场：提供一个平台允许用户之间安全转让票务NFT，每次交易都通过智能合约来验证和记录


