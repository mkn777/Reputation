// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.24 <0.9.0;

import "./Mytoken.sol";
import {ABDKMathQuad} from "./ABDKMathQuad.sol";



contract Reputation {

    //token to send award for rating
    Mytoken public mytoken = new Mytoken();
    address public seller;
    bool access = false;
    //arrays to store positive and negative ratings
    uint[] public posratings; 
    int[] public negratings; 

    uint[] public times; 

    uint8 constant public beta = 7;

   // event rateprocess(string message , bool check);

    //Every rater(customer) has a struct type
    struct Customer{
        uint[] ratingm;
        uint[] time;
        uint count; 
        uint[] price;
    }


    mapping(address => Customer) public raters;

    constructor(){ 
        seller = msg.sender;
    }

    function addnewtoken() public { 
        require(msg.sender == seller);
        mytoken.mint(20);
    }
    function gettokencounts() public view returns(uint){
        return mytoken.totalSupply();
    }

    function checktokenbalance(address tokenOwner) public view returns(uint){ 
        return mytoken.balanceOf(tokenOwner);

    }
    
    function accessgiven() public { 

        if(msg.sender == seller){
            access = true;
           // emit rateprocess("Rate proces begin" , true);
        }
        else{
            access = false;
        }
    }

    function timedecay(uint blocktime) public view returns (uint){ 

        uint currenttime = block.timestamp;

        uint result = (currenttime - blocktime) / 60 / 60 / 24;

        if(result < 8){
            return 1;
        }
        else if(result > 7 && result < 31) {
            return 8;
        }
        else if(result > 30 && result < 91){
            return 6;
        }
        else { 

            return 5;
        }

    }

    function timecalculate(uint current , uint last) public pure returns(uint)
    {

        return (current - last) / 60 / 60 / 24;
    }

    function rate(uint8 status , uint rating , uint price) public   { 

        require(access);
        uint len = raters[msg.sender].time.length;
        uint lasttime;
        uint currenttime;
        uint timediff;

        if(len != 0){
          lasttime = raters[msg.sender].time[len-1];
        }

        raters[msg.sender].ratingm.push(rating);
        raters[msg.sender].time.push(block.timestamp);
        raters[msg.sender].count += 1;
        raters[msg.sender].price.push(price); 
        times.push(block.timestamp);
        uint test = raters[msg.sender].count;

        uint newlen = raters[msg.sender].time.length;

         if(len != 0){

                currenttime = raters[msg.sender].time[newlen-1];
                timediff = timecalculate(currenttime , lasttime);
            
        }
        
        uint result = checkfreq(test - 1 , timediff);
        uint result2 = calculateprice(price);
        uint posres;
        
        if(rating == 0){
            posres = rating + (result * result2);
            if(status == 1){
                posratings.push(posres);
             }
             else{
                 negratings.push(-1 * int(posres));
             }
        }
        else{ 

             posres = (rating * result * result2);
             if(status == 1){
                posratings.push(posres);
             }
             else{
                 negratings.push(-1 * int(posres));
             }

        }

        sendprize(msg.sender , price);

    }

    function contractaddress() public view returns(address test){ 

        return address(this);

    }

    function calculateprice(uint price) public pure returns(uint){

        if(price <= 20){ 
            return 1;
        }
        else{
        bytes16 number1 = ABDKMathQuad.fromUInt(price + 1);
        bytes16 result =  ABDKMathQuad.ln(number1);

        uint res = ABDKMathQuad.toUInt(result);

        if(res >=5){
            return 5;
        }
        else {
          return  res;

        }
        }

    }

    function checkfreq(uint temp , uint tresult) public pure returns(uint){

        if(tresult >=3){ 

            return 5;
        }
        else {

        bytes16 number1 = ABDKMathQuad.fromUInt(5);
        bytes16 number2 = ABDKMathQuad.fromUInt(temp);
        bytes16 number3 = ABDKMathQuad.fromUInt(7);
        bytes16 number4 = ABDKMathQuad.div(number2 , number3);
        bytes16 number5 = ABDKMathQuad.exp(number4);
        bytes16 result = ABDKMathQuad.div(number1 , number5);
        return ABDKMathQuad.toUInt(result);
        }
    }

    function division(uint num1 , uint num2) public pure returns(bytes16){ 

        bytes16 number1 = converttobytes(num1);
        bytes16 number2 = converttobytes(num2);
        return ABDKMathQuad.div(number1 , number2);
    }

    function converttobytes(uint256 number) public pure returns(bytes16){
        return ABDKMathQuad.fromUInt(number);
    }

    function converttoint(bytes16 number) public pure returns(int){
        return ABDKMathQuad.toInt(number);
    }

    function sendprize(address addi , uint price) private  returns (bool) { 

       
        uint values2 = uint((price/100) + 1);
       // bool success = testaddress.send(values2);
       //(bool success, bytes memory data) = testaddress.call{value: values2}("");
        return  mytoken.transfer(addi , values2);
    }

    function getClientRecord(address test) public view returns (Customer memory){
        return raters[test];
    }
    /*
    function getOverallRep() public view returns(uint){ 

        uint sum =0;

        for(uint i= 0; i< posratings.length;i++){ 


                uint impact = timedecay(times[i]);

                sum = sum + posratings[i]*impact;
        }
       return sum/posratings.length;
    }*/

    function calculaterep() public view returns(uint){

        uint posrate = getallposratings();

        uint negrate = uint(-1 * getallnegratings());

        uint overall = posrate + negrate;


      

        if(negrate == posrate){
            return 0;
        }
        else if(negrate > posrate){
            uint med = negrate - posrate;
            return (med*10)/overall;
        }
        else{ 

            return (posrate*10) / overall;

            
        }
    }
    function getallposratings() public view returns(uint){

        uint sum =0;

        for(uint i= 0; i< posratings.length;i++){ 

                uint impact = timedecay(times[i]);
                sum = sum + posratings[i]*impact;

        }
       return sum;

    }
    function getallnegratings() public view returns(int){ 

        int sum =0;

        for(uint i= 0; i< negratings.length;i++){ 

                sum = sum + negratings[i];
        }
       return sum;
    }

    function getRatings() public view returns(uint[] memory){

        return posratings;
    }
    function getnegRatings() public view returns(int[] memory){

        return negratings;
    }

}