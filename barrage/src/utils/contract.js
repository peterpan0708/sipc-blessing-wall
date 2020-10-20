import detectEthereumProvider from "@metamask/detect-provider";
import Contract from "web3-eth-contract";
import abi from "../utils/abi/blessing.json";

export async function connectContract() {
  const provider = await detectEthereumProvider();
  Contract.setProvider(provider);
  return new Contract(abi, "0x395392a02768ba33e13daf161bcb0647b6a9f418");
}

export async function notConnectContract() {
  Contract.setProvider("http://47.101.31.92:18546/");
  return new Contract(abi, "0x395392a02768ba33e13daf161bcb0647b6a9f418");
}
