export async function suite(h) {
  const c = await h.deploy("ThresholdTreasury", [
    [h.addresses[0], h.addresses[1], h.addresses[2]],
    2,
    10,
  ]);
  await h.tx(h.signers[0].sendTransaction({ to: c.target, value: 1000 }));
  await h.tx(c.submit(h.addresses[3], 500, "0x"));
  await h.test("nonowner cannot approve", () =>
    h.revert(() => c.connect(h.signers[3]).approve(0)),
  );
  await h.test("approval threshold enforced", async () => {
    await h.tx(c.approve(0));
    await h.revert(() => c.execute(0));
  });
  await h.test("duplicate approval rejected", () =>
    h.revert(() => c.approve(0)),
  );
  await h.test("revocation decreases approval count", async () => {
    await h.tx(c.revoke(0));
    h.eq((await c.transaction(0)).approvals, 0n);
    await h.tx(c.approve(0));
    await h.tx(c.connect(h.signers[1]).approve(0));
  });
  await h.test("delay enforced", () => h.revert(() => c.execute(0)));
  await h.test("permissionless execution occurs once", async () => {
    await h.mine(11);
    await h.tx(c.connect(h.signers[3]).execute(0));
    h.eq((await c.transaction(0)).executed, true);
    await h.revert(() => c.execute(0));
  });
}
