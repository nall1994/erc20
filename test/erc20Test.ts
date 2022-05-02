import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ERC20 } from "../typechain";

describe("test ERC20 token contract", async () => {
    let erc20: ERC20;
    let signers: SignerWithAddress[];
    const initialSupply = 5000000;
    const tokenName = "Bucks Bunny";
    const tokenSymbol = "BKB";
    const decimals = 8;

    before(async () => {
        signers = await ethers.getSigners();
    });

    beforeEach(async () => {
        const ERC20 = await ethers.getContractFactory("ERC20");
        erc20 = await ERC20.deploy(initialSupply, tokenName, tokenSymbol, decimals);
    });

    it('Should return the name of the token', async () => {
        const name = await erc20.name();
        expect(name).to.equal(tokenName);
    });

    it('Should return the symbol of the token', async () => {
        const symbol = await erc20.symbol();
        expect(symbol).to.equal(tokenSymbol);
    });

    it('Should return the decimal units used', async () => {
        const decimalUnits = await erc20.decimals();
        expect(decimalUnits).to.equal(decimals);
    });

    it('Should return the total supply', async () => {
        const totalSupply = await erc20.totalSupply();
        expect(totalSupply).to.equal(initialSupply);
    });

    it('Should return the balance of an account', async () => {
        const balance = await erc20.balanceOf(signers[1].address);
        expect(balance).to.equal(0);
    });

    it('Should transfer tokens to another account', async () => {
        const value = 20;
        const owner = signers[0].address;
        const recipient = signers[1].address;
        await erc20.transfer(recipient, value);

        const ownerBalance = await erc20.balanceOf(owner);
        const recipientBalance = await erc20.balanceOf(recipient);
        expect(ownerBalance).to.equal(initialSupply - value);
        expect(recipientBalance).to.equal(value);
    });

    it('Should transfer tokens from one account to another after approval', async () => {
        const value = 10;
        const payer = signers[1].address;
        const spender = signers[2].address;
        const recipient = signers[3].address;
        await erc20.transfer(payer, value);

        await erc20.connect(signers[1]).approve(spender, value);
        await erc20.connect(signers[2]).transferFrom(payer, recipient, value);

        const payerBalance = await erc20.balanceOf(payer);
        const recipientBalance = await erc20.balanceOf(recipient);

        expect(payerBalance).to.equal(0);
        expect(recipientBalance).to.equal(value);
    });

    it('Should return an allowance for a sender', async () => {
        const allower = signers[1].address;
        const spender = signers[2].address;

        const allowance = await erc20.allowance(allower, spender);

        expect(allowance).to.equal(0);
    });

    it('Should approve an allowance for a sender', async () => {
        const value = 20;
        const allower = signers[1].address;
        const spender = signers[2].address;
        await erc20.transfer(allower, value);

        await erc20.connect(signers[1]).approve(spender, value, {from: allower});
        const allowance = await erc20.allowance(allower, spender);

        expect(allowance).to.equal(value);
    });

    it('Should mint new tokens', async () => {
        const value = 20;
        const recipient = signers[1].address;
        await erc20.mint(recipient, value);

        const recipientBalance = await erc20.balanceOf(recipient);
        const totalSupply = await erc20.totalSupply();

        expect(recipientBalance).to.equal(value);
        expect(totalSupply).to.equal(initialSupply + value);
    });

    it('Should burn tokens', async () => {
        const value = 10;
        const recipient = signers[1].address;
        await erc20.transfer(recipient, 20);
        await erc20.burn(recipient, value);

        const recipientBalance = await erc20.balanceOf(recipient);
        const totalSupply = await erc20.totalSupply();

        expect(recipientBalance).to.equal(value);
        expect(totalSupply).to.equal(initialSupply - value);
    });

    it('Should not allow transfering tokens from one account to another if there is no approval', async () => {
        const value = 10;
        const payer = signers[1].address;
        const spender = signers[2]
        const recipient = signers[3].address;
        await erc20.transfer(payer, value);

        await expect(erc20.connect(spender).transferFrom(payer, recipient, value))
            .to.be.revertedWith('not enough allowance');
    });

    it('Should not allow a transfer without enough funds', async () => {
        const value = 20;
        const payer = signers[1];
        const recipientAddress = signers[2].address;

        await expect(erc20.connect(payer).transfer(recipientAddress, value))
            .to.be.revertedWith('value higher than balance');
    });

    it('Should not allow a transfer from one to another with allowance if balance is lesser', async () => {
        const value = 20;
        const payer = signers[1].address;
        const spender = signers[2].address;
        const recipient = signers[3].address;
        await erc20.transfer(payer, 10);

        await expect(erc20.connect(signers[2]).transferFrom(payer, recipient, value)).to.be.revertedWith('not enough balance');
    });;

    it('Should not allow a transfer from one to another if there isn\'t enough allowance' , async () => {
        const value = 10;
        const payer = signers[1].address;
        const spender = signers[2].address;
        const recipient = signers[3].address;
        await erc20.transfer(payer, 20);

        await erc20.connect(signers[1]).approve(spender, value);
        await expect(erc20.connect(signers[2]).transferFrom(payer, recipient, 20)).to.be.revertedWith('not enough allowance');
    });

    it('Should not burn tokens when the existent amount is smaller', async () => {
        const value = 20;
        await erc20.transfer(signers[1].address, 10);

        await expect(erc20.burn(signers[1].address, value)).to.be.revertedWith('amount lower than existent');
    });

    it('Should not mint tokens if caller is not the owner', async () => {
        const value = 20;
        await expect(erc20.connect(signers[1]).mint(signers[2].address, value)).to.be.revertedWith("Access denied, only owner");
    });

    it('Should not burn tokens if caller is not the owner', async () => {
        const value = 20;
        await erc20.transfer(signers[2].address, value);

        await expect(erc20.connect(signers[1]).burn(signers[2].address, value)).to.be.revertedWith("Access denied, only owner");
    });
});