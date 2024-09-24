class Transaction {
  constructor(options) {
	this.options = options;
	this.confirmations = [];
  }

  createTransaction() {
	return new Promise((resolve, reject) => {
	  /* Transaction logic here */
      resolve('todo: implement create transaction functoin')
	});
  }

  confirmTransaction(nodeId) {
	this.confirmations.push({ nodeId, timestamp: new Date() });
  }

  getConfirmationCount() {
	return this.confirmations.length;
  }

  getConfirmationHistory() {
	return this.confirmations;
  }

  validateTransaction() {
	/* Logic for validating the transaction based on confirmations */
  }
}

Transaction.factory = async function(options) {
    const transaction = new Transaction(options);
    return transaction.createTransaction()
        .then(() => {
            transaction.confirmTransaction(nodeId);
            const confirmationCount = transaction.getConfirmationCount();
            console.log(`Transaction confirmed by ${confirmationCount} nodes.`);
            const confirmationHistory = transaction.getConfirmationHistory();
            console.log("Confirmation history:", confirmationHistory);
            transaction.validateTransaction();
        })
        .catch((error) => {
            console.error("Error creating transaction:", error);
        });
}

module.exports = Transaction;
