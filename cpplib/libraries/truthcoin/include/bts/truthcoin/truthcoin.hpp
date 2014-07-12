/* This file defines the market- and consensus-related functions
 *
 * You might find the following files useful:
 *    Truthcoin/rlib/market/Markets.r
 *    Truthcoin/rlib/market/Trading.R
 *
 * TODO define consensus methods
 */

#pragma once

namespace bts { namespace truthcoin {

    using namespace std;

    /* A market in whatever form you need to do your calculations.
     * You may change this however you like (for example, to use types defined
     * by a matrix library), but the constructor should have the same type signature.
     *
     * Bonus points if you can do all computations in-place (hence the reference types
     * in the default market definition, avoid excess copies) - I know this is possible
     * at least for the market-only (but maybe not consensus) functions.
     *
     * You are free to come up with your own conventions for how to interpret the flat vector
     * as an n-dimensional market.
     *
     * You are also free to drop floats in favor of int64_t if it helps with rounding issues.
     */
    typedef int DecisionID;
    struct Market
    {
        vector<float>& values;
        vector<DecisionID>& decisions;
        vector<int>& dimensions; // for interpreting decision->value mapping
        float liquidity_parameter;
        float trading_fee;

        Market(vector<float>& values, vector<int>& dimensions,
               vector<DecisionID> decisions,
               float liquidity_paramter, float trading_fee)
            :values(values),dimensions(dimensions),decisions(decisions)
            liquidity_paramter(liquidity_parameter),trading_fee(trading_fee){}
    }


    typedef int MarketState; // an index into Market.values
    typedef vector<float> Outcomes; // maps 1-to-1 wth decisions


    // In Trading.R
    float QueryMove(Market& market, MarketState state, float target_probability);
    float QueryCost(Market& market, MarketState state, float desired_shares);
    float Buy(Market& market, MarketState state, float target_probability);
    float Sell(Market& market, MarketState state, float target_probability);
    float Redeem(Market& market, MarketState state, float number_of_shares);

    // In Markets.r
    vector<float> GetFinalPrices(Market& market, Outcomes& outcomes);


}} // bts::truthcoin
