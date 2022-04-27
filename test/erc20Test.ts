import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "hardhat";
import { ERC20 } from "../typechain";

describe("test ERC20 token contract", async () => {
    let erc20: ERC20;
    let signers: SignerWithAddress[];

    before(async () => {
        signers = await ethers.getSigners();
    });

    beforeEach(async () => {
        const ERC20 = await ethers.getContractFactory("ERC20");
        erc20 = await ERC20.deploy();
    });
});