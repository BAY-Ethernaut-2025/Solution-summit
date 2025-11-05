await contract.contribute({value: toWei("0.00001")})
await sendTransaction({from: player, to: instance, value: toWei("0.00000000000001")})
await contract.withdraw()