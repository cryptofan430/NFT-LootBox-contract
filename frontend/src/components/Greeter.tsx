import React, { useContext, useEffect, useState } from "react";
import { LootBoxesContext } from "./../hardhat/SymfoniContext";
import { ethers } from "ethers";
import LootBoxesDeployment from "./../hardhat/deployments/ropsten/LootBoxes.json";


interface Props {}

export const Greeter: React.FC<Props> = () => {
  const greeter = useContext(LootBoxesContext);
  const [message, setMessage] = useState("");
  const [inputGreeting, setInputGreeting] = useState("");
  useEffect(() => {
    const doAsync = async () => {
      if (!greeter.instance) return;
      console.log("Greeter is deployed at ", greeter.instance.address);
      // setMessage(await greeter.instance.greet());
    };
    doAsync();
  }, [greeter]);

  const handleSetGreeting = async (
    e: React.MouseEvent<HTMLButtonElement, MouseEvent>
  ) => {
    e.preventDefault();
    
    
    if (!greeter.instance) throw Error("Greeter instance not ready");
    if (greeter.instance) {
      // const tx = await greeter.instance.setGreeting(inputGreeting);
      // console.log("setGreeting tx", tx);
      // await tx.wait();

      // const provider = new ethers.providers.Web3Provider(window.ethereum)
      // const signer = provider.getSigner();

      // const contract = new ethers.Contract(greeter.instance?.address, LootBoxesDeployment.abi, signer)
      
      // try{
      //   let result = await contract.drawItem(inputGreeting)
      //   console.log(result, "------")
      // } catch(err) {
      //   console.log("Error: ", err)
      // }


      const tx = await greeter.instance.drawItem(inputGreeting);
      
      console.log("New greeting mined, result: ", tx);
      
      setMessage(tx);

      // greeter.instance.on("Draws", (from, to, value, event) => {

      //   console.log(from,to,value);
    
      //   console.log(event.blockNumber);
    
      // });

      
      setInputGreeting("");
    }
  };
  return (
    <div>
      <p>{message}</p>
      <input
        value={inputGreeting}
        onChange={(e) => setInputGreeting(e.target.value)}
      ></input>
      <button onClick={(e) => handleSetGreeting(e)}>Set greeting</button>
    </div>
  );
};
