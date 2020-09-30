import detectEthereumProvider from "@metamask/detect-provider";
import Contract from "web3-eth-contract";
import abi from "../utils/abi/blessing.json";

export async function connectContract() {
  const provider = await detectEthereumProvider();
  Contract.setProvider(provider);
  return new Contract(abi, "0x457263f030e57432730f5de41780e0e88c289ad7");
}

export async function NotConnectContract() {
  Contract.setProvider("http://47.101.31.92:18546/");
  this.contract = new Contract(
    abi,
    "0x457263f030e57432730f5de41780e0e88c289ad7"
  );
}
