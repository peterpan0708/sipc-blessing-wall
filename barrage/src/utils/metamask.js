import MetaMaskOnboarding from "@metamask/onboarding";

export default {
  isMetaMaskInstalled() {
    const { ethereum } = window;
    return Boolean(ethereum && ethereum.isMetaMask);
  },

  onClickInstall() {
    const onboarding = new MetaMaskOnboarding({
      forwarderOrigin: window.location.origin
    });
    onboarding.startOnboarding();
  },

  async onClickConnect() {
    try {
      const { ethereum } = window;
      await ethereum.request({ method: "eth_requestAccounts" });
    } catch (error) {
      console.error(error);
    }
  },

  async getAccounts() {
    try {
      //Will Start the MetaMask Extension
      const { ethereum } = window;
      return await ethereum.request({ method: "eth_accounts" });
    } catch (error) {
      console.error(error);
      return [];
    }
  }
};
