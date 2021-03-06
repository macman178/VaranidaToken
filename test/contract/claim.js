'use strict';

var Varanida = artifacts.require("./Varanida.sol");
const Time = require("../helpers/time.js");

contract('Varanida - claim tokens', function(accounts) {

  const owner = accounts[0],
  advisor = accounts[1],
  founder = accounts[2],
  technical = accounts[3],
  year = 60*60*24*365,
  allocateAmount = Math.pow(10,18);

  it("advisors should not claim more tokens than they are allowed to", function() {
    var vara, nb_calls = 0;
    return Varanida.new() // Redeploy Varanida contract
      .then(function(instance) {
        vara = instance;
        nb_calls++;
        return vara.allocate(advisor, 100*allocateAmount, 1, {from: owner});
      }).then(function(){
        nb_calls++;
        return vara.claimTokens(advisor, 101*allocateAmount, 1, {from: advisor});
      }).then(function() {
        assert.fail('This won\'t happen.');
      }).catch(function(err) {
        assert(err.message.search('revert') >= 0);
      }).then(function(){
        nb_calls++;
        return vara.claimTokens(advisor, 100*allocateAmount, 1, {from: advisor});
      }).then(function() {
        nb_calls++;
        return vara.balanceOf(advisor, {from: advisor});
      }).then(function(result){
        assert(result.toNumber()===100*allocateAmount);
        assert(nb_calls === 4);
      });
  });

  it("founders should not claim more tokens than they are allowed to", function() {
    var vara, nb_calls = 0;
    return Varanida.new() // Redeploy Varanida contract
      .then(function(instance) {
        vara = instance;
        nb_calls++;
        return vara.allocate(founder, 100*allocateAmount, 2, {from: owner});
      }).then(function(){
        return Time.increaseTime(year);
      }).then(function(){
        nb_calls++;
        return vara.claimTokens(founder, allocateAmount, 2, {from: founder});
      }).then(function() {
        assert.fail('This won\'t happen.');
      }).catch(function(err) {
        assert(err.message.search('revert') >= 0);
      }).then(function() {
        return Time.increaseTime(0.5*year);
      }).then(function() {
        nb_calls++;
        return vara.claimTokens(founder, 51*allocateAmount, 2, {from: founder});
      }).then(function() {
        assert.fail('This won\'t happen.');
      }).catch(function(err) {
        assert(err.message.search('revert') >= 0);
      }).then(function() {
        nb_calls++;
        return vara.claimTokens(founder, 50*allocateAmount, 2, {from: founder});
      }).then(function() {
        nb_calls++;
        return vara.balanceOf(founder, {from: founder});
      }).then(function(result){
        assert(result.toNumber()===50*allocateAmount);
      }).then(function() {
        return Time.increaseTime(year);
      }).then(function() {
        nb_calls++;
        return vara.claimTokens(founder, 51*allocateAmount, 2, {from: founder});
      }).then(function() {
        assert.fail('This won\'t happen.');
      }).catch(function(err) {
        assert(err.message.search('revert') >= 0);
      }).then(function() {
        nb_calls++;
        return vara.claimTokens(founder, 50*allocateAmount, 2, {from: founder});
      }).then(function() {
        nb_calls++;
        return vara.balanceOf(founder, {from: founder});
      }).then(function(result){
        assert(result.toNumber()===100*allocateAmount);
        assert(nb_calls === 8);
      });
  });

  it("technicals should not claim more tokens than they are allowed to", function() {
    var vara, nb_calls = 0;
    return Varanida.new() // Redeploy Varanida contract
      .then(function(instance) {
        vara = instance;
        nb_calls++;
        return vara.allocate(technical, 100*allocateAmount, 3, {from: owner});
      }).then(function() {
        return Time.increaseTime(0.5*year);
      }).then(function() {
        nb_calls++;
        return vara.claimTokens(technical, allocateAmount, 3, {from: technical});
      }).then(function() {
        assert.fail('This won\'t happen.');
      }).catch(function(err) {
        assert(err.message.search('revert') >= 0);
      }).then(function(){
        return Time.increaseTime(0.25*year);
      }).then(function(){
        nb_calls++;
        return vara.claimTokens(technical, 51*allocateAmount, 3, {from: technical});
      }).then(function() {
        assert.fail('This won\'t happen.');
      }).catch(function(err) {
        assert(err.message.search('revert') >= 0);
      }).then(function(){
        nb_calls++;
        return vara.claimTokens(technical, 50*allocateAmount, 3, {from: technical});
      }).then(function() {
        nb_calls++;
        return vara.balanceOf(technical, {from: technical});
      }).then(function(result){
        assert(result.toNumber()===50*allocateAmount);
      }).then(function(){
        return Time.increaseTime(0.5*year);
      }).then(function(){
        nb_calls++;
        return vara.claimTokens(technical, 51*allocateAmount, 3, {from: technical});
      }).then(function() {
        assert.fail('This won\'t happen.');
      }).catch(function(err) {
        assert(err.message.search('revert') >= 0);
      }).then(function(){
        nb_calls++;
        return vara.claimTokens(technical, 50*allocateAmount, 3, {from: technical});
      }).then(function() {
        nb_calls++;
        return vara.balanceOf(technical, {from: technical});
      }).then(function(result){
        assert(result.toNumber()===100*allocateAmount);
        assert(nb_calls === 8);
      });
  });

  it("should update totalSupply_", function() {
    var vara, nb_calls = 0;
    return Varanida.new() // Redeploy Varanida contract
      .then(function(instance) {
        vara = instance;
        nb_calls++;
        return vara.allocate(advisor, 101*allocateAmount, 1, {from: owner});
      }).then(function() {
        nb_calls++;
        return vara.allocate(founder, 110*allocateAmount, 2, {from: owner});
      }).then(function() {
        nb_calls++;
        return vara.allocate(technical, 11*allocateAmount, 3, {from: owner});
      }).then(function(){
        return Time.increaseTime(2*year);
      }).then(function(){
        nb_calls++;
        return vara.claimTokens(advisor, 101*allocateAmount, 1, {from: advisor});
      }).then(function(){
        nb_calls++;
        return vara.claimTokens(founder, 110*allocateAmount, 2, {from: founder});
      }).then(function(){
        nb_calls++;
        return vara.claimTokens(founder, 11*allocateAmount, 3, {from: technical});
      }).then(function() {
        nb_calls++;
        return vara.totalSupply({from: advisor});
      }).then(function(result){
        assert(result.toNumber()===222*allocateAmount);
        assert(nb_calls === 7);
      });
  });

});
