const Transaction = require('./transaction.js');
let transaction;

describe('Transaction class', () => {
    beforeEach(async () => {
        transaction = await Transaction.factory({
            amount: 300,
            sender: "alice@mailinator.com",
            recepient: "bob@mailinator.com",
            message: "🚜"
        });
    })
    it('should create a transaction successfully', async () => {
        expect(transaction.amount).toEqual(300);
        expect(transaction.message).toEqual("🚜");
        expect(transaction.sender).toEqual("alice@mailinator.com");
        expect(transaction.recepient).toEqual("bob@mailinator.com");
    }); 
});


