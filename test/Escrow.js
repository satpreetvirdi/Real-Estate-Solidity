const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether')
}

    describe('Escrow', () => {
        let buyers,sellers;
        let realEstate,escrow;
    
        beforeEach(async ()=>{
            [buyers,sellers,inspector,lender] = await ethers.getSigners();
            
    
            // Deploy
           const RealEstate = await ethers.getContractFactory('RealEstate')
           realEstate = await RealEstate.deploy();
        //    console.log(realEstate.address);
    
            // Mint
            let transaction  = await realEstate.connect(sellers).mint("https://ipfs.io/ipfs/QmTudSYeM7mz3PkYEWXWqPjomRPHogcMFSq7XAvsvsgAPS");
            await transaction.wait();

            const Escrow = await ethers.getContractFactory("Escrow");
            escrow = await Escrow.deploy(lender.address,sellers.address,inspector.address, realEstate.address);

              // Approve Property
                 transaction = await realEstate.connect(sellers).approve(escrow.address, 1)
                await transaction.wait()

        // List Property
        transaction = await escrow.connect(sellers).list(1, tokens(10), tokens(5), buyers.address)
        await transaction.wait()
        })   
       
            
        describe("Deployment",()=>{
            it('Returns Lender',async ()=>{
                const results  = await escrow.lender;
                expect(results === lender.address);  
            })
        
            it('Returns the NFT address',async ()=>{
                const results  = await escrow.nftAddress;
                expect(results === realEstate.address);  
            })
            it('Returns the seller',async ()=>{
                const results  = await escrow.sellers;
                    expect(results === sellers.address);  
            })
            it('Returns the inspector',async ()=>{
                const results  = await escrow.inspector;
                expect(results === inspector.address);  
            })
        })   
        
        
        describe("Listing",()=>{
            it('Updates as listed', async () => {
                const result = await escrow.isListed(1)
                expect(result).to.be.equal(true)
            })
        
            it('Returns buyer', async () => {
                const result = await escrow.buyer(1)
                expect(result).to.be.equal(buyers.address)
            })
        
            it('Returns purchase price', async () => {
                const result = await escrow.purchasePrice(1)
                expect(result).to.be.equal(tokens(10))
            })
        
            it('Returns escrow amount', async () => {
                const result = await escrow.escrowAmount(1)
                expect(result).to.be.equal(tokens(5))
            })
        
            it('Updates ownership', async () => {
                expect(await realEstate.ownerOf(1)).to.be.equal(escrow.address)
            })
        
            
        })
        
    })
    






