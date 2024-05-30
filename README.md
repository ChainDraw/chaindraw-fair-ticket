# ChainDraw-FairTicket
## Project Introduction
ChainDraw is a decentralized concert ticketing platform that uses blockchain technology and NFTs to ensure fair and transparent ticket distribution. By leveraging Chainlink VRF for random and verifiable draws, ChainDraw guarantees that every participant has an equal chance of winning. To prevent multiple registrations and scalping, participants are required to pay an equivalent deposit during the subscription phase. This measure ensures that the cost of cheating outweighs the potential benefits, discouraging malicious activities.NFT-based tickets provide a unique, tamper-proof record for each ticket, and secondary market transactions are monitored to prevent price gouging and ensure fair access.Before the concert ends, tickets can only be transferred to the market contract for sale, and the selling price cannot exceed the original face value. This prevents price speculation and black market transactions. Once the concert ends, these restrictions will be lifted, allowing tickets to be freely transferred and sold without price limitations.

## How we built it
The platform is based on Ethereum, with **smart contracts** written in **Solidity** to handle ticket issuance, distribution, and validation. We use **Chainlink VRF** to generate verifiable random numbers for the ticket lottery, ensuring transparency and fairness. 
#### Implement "NFT Transfer Restrictions," "Sale Restrictions," "Lottery Transparency"
- Rewrite the ERC721 `_transfer` function to implement transfer restrictions.
    - Concert ongoing: Users can only sell and buy tickets through the market contract, enabling Ticket transfers.
    - Concert ended: Users can freely transfer their NFT Tickets.
- Utilize the Factory design pattern to build the lottery contract, ensuring a one-to-one relationship between concert ticket types and the lottery pool, enhancing lottery transparency.
    1. Every ticket lottery contract created by a user is managed through the factory contract, ensuring that unregistered contracts cannot be listed. This ensures the stability of the market contract and serves only validly registered users.
    2. Sale price control:
        - Concert ongoing: Sale price cannot exceed the original price (the deposit paid during the lottery).
        - Concert ended: No price limit on sales.
    3. User identity verification: NFTs are bound to user information to achieve "one person, one ticket," providing dual verification.
        - Dual verification: 1. Users prove they own the NFT for the event. 2. Users prove the identity information bound to the NFT is theirs.
