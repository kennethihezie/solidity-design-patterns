const { abi, bytecode } = require('../config')
const assert = require('assert')
const { web3 } = require('hardhat')

let accounts
let contract

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();
    contract = await new web3.eth.Contract(abi)
    .deploy({ data: bytecode })
    .send({ from: accounts[0], gas: '1000000'})
})

describe('Design Pattern', () => {
    it('deploy\'s contract', async () => {
        assert.ok(contract.options.address)
    })

    it('transfer to an address', async () => {
        const balance = await web3.eth.getBalance(accounts[1]);
        await contract.methods.transfer(accounts[1]).send({ from: accounts[0], value: '2000' })
        const newBalance = await web3.eth.getBalance(accounts[1]);
        assert.notEqual(balance, newBalance)
    })
    it('send to an address', async () => {
        const balance = await web3.eth.getBalance(accounts[1]);
        await contract.methods.send(accounts[1]).send({ from: accounts[0], value: '2000' })
        const newBalance = await web3.eth.getBalance(accounts[1]);
        assert.notEqual(balance, newBalance)
    })
    it('call to an address', async () => {
        const balance = await web3.eth.getBalance(accounts[1]);
        await contract.methods.call(accounts[1]).send({ from: accounts[0], value: '2000' })
        const newBalance = await web3.eth.getBalance(accounts[1]);
        assert.notEqual(balance, newBalance)
    })
    it("contribute", async () => {
        await contract.methods.contribute(accounts[2]).send({from: accounts[0], value: '10'})
    })
    it('generate a random number', async () => {
        await contract.methods.random().call()
    })
    it('listen for changes in the event method', async () => {
        await contract.events.Deposit((error, result) => {
            if(!error){
                console.log(result);
            }
        })

        //call the deposit method
        await contract.methods.deposit('collins').send({ from: accounts[0], value: '100' })
    })
    
})