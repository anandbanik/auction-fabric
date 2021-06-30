package com.art.nft.auth.contract;

import java.util.ArrayList;
import java.util.List;

import org.hyperledger.fabric.Logger;
import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.contract.annotation.Contract;
import org.hyperledger.fabric.contract.annotation.Default;
import org.hyperledger.fabric.contract.annotation.Info;
import org.hyperledger.fabric.contract.annotation.Transaction;
import org.hyperledger.fabric.shim.ChaincodeStub;
import org.hyperledger.fabric.shim.ledger.KeyModification;
import org.hyperledger.fabric.shim.ledger.QueryResultsIterator;

import com.art.nft.auth.model.AssetAuthenticate;
import com.art.nft.auth.model.AssetAuthentication;
import com.art.nft.auth.model.AssetHistory;
import com.art.nft.auth.model.Response;
import com.art.nft.auth.util.AuthenticationConstants;
import com.owlike.genson.Genson;

@Contract(name = "authentication-chaincode", info = @Info(title = "Authentication Contract", description = "Auction-House Authentication Smart-Contract", version = "1.0.0"))
@Default
public class AuctionAuthentication implements ContractInterface {

	private static final Logger LOGGER = Logger.getLogger(AuctionAuthentication.class);
	private final Genson genson = new Genson();


	/**
	 * The Function to initialize the ledger
	 *
	 * @param ctx			Context Chaincode context
	 * @return null
	 */


	@Transaction()
	public void initLedger(final Context context) {
		LOGGER.info("Initializing ledger for POTraceEventSmartContract");
		ChaincodeStub stub = context.getStub();
		try {
			stub.putStringState(AuthenticationConstants.INIT_LEDGER_KEY, AuthenticationConstants.INIT_LEDGER_VALUE);
		} catch (Exception e) {
			LOGGER.error("Exception occured while initializing ledger : " + e);
		}
	}

	@Transaction()
	public String initQuery(final Context context) {
		LOGGER.debug("initQuery method is invoked");
		ChaincodeStub stub = context.getStub();
		return stub.getStringState(AuthenticationConstants.INIT_LEDGER_KEY);
	}

	/**
	 * Health Check
	 * 
	 * @param ctx
	 */
	@Transaction()
	public String health(final Context ctx) {
		return "status - ok";
	}

	/**
	 * The Function to create the Art Asset
	 *
	 * @param ctx			Context Chaincode context
	 * @param authPayload   String Payload to create the asset
	 * @return response		Response<String> Response object with the created asset Payload
	 */

	@Transaction()
	public Response<String> createArtAsset(final Context ctx, final String assetPayload) {
		Response<String> response = new Response<>();
		try {
			LOGGER.info("Invoking createArtAsset method.");
			ChaincodeStub stub = ctx.getStub();
			String clientId = ctx.getClientIdentity().getMSPID();
			if (null != clientId && !clientId.isEmpty()
					&& clientId.equalsIgnoreCase(AuthenticationConstants.CREATE_ASSET_OWNER)) {
				AssetAuthentication assetAuthentication = genson.deserialize(assetPayload, AssetAuthentication.class);
				String key = String.valueOf(Math.abs(assetAuthentication.hashCode()));
				response.setTransactionId(key);
				assetAuthentication.setStatus(null);
				assetAuthentication.setAuthBy(null);
				assetAuthentication.setAuthTs(null);
				String strAuthAsset = genson.serialize(assetAuthentication);
				stub.putStringState(key, strAuthAsset);
				response.setResponse(strAuthAsset);
				stub.setEvent("asset_created#ID" + key, strAuthAsset.getBytes());
			} else {
				LOGGER.error("Only Auction House can create asset");
				response.setError("Only Auction House can create asset");
				response.setResponse(null);
			}

		} catch (Exception ex) {
			LOGGER.error("Error in updating Art Asset to ledger " + ex.getMessage());
			response.setError(ex.getMessage());
			response.setResponse(null);
		}

		return response;
	}

	/**
	 * The Function to authenticate the Art Asset
	 *
	 * @param ctx			Context Chaincode context
	 * @param authPayload   String Payload to authenticate the asset
	 * @return response		Response<String> Response object with the updated asset Payload
	 */

	@Transaction()
	public Response<String> authenticateAsset(final Context ctx, final String authPayload) {
		Response<String> response = new Response<>();
		try {
			LOGGER.info("Invoking authenticateAsset method.");
			ChaincodeStub stub = ctx.getStub();
			String clientId = ctx.getClientIdentity().getMSPID();
			if (null != clientId && !clientId.isEmpty()
					&& clientId.equalsIgnoreCase(AuthenticationConstants.AUTHENTICATE_ASSET)) {

				AssetAuthenticate assetAuthenticate = genson.deserialize(authPayload, AssetAuthenticate.class);
				String assetPayload = stub.getStringState(assetAuthenticate.getAssetId());
				if (null != assetPayload && !assetPayload.isEmpty()) {
					AssetAuthentication assetAuthentication = genson.deserialize(
							stub.getStringState(assetAuthenticate.getAssetId()), AssetAuthentication.class);
					assetAuthentication.setStatus(assetAuthenticate.getStatus());
					assetAuthentication.setAuthBy(assetAuthenticate.getAuthBy());
					assetAuthentication.setAuthTs(assetAuthenticate.getAuthTs());
					String key = assetAuthenticate.getAssetId();
					response.setTransactionId(key);
					String strAuthAsset = genson.serialize(assetAuthentication);
					stub.putStringState(key, strAuthAsset);
					response.setResponse(strAuthAsset);
					stub.setEvent("asset_authenticated#ID" + key, strAuthAsset.getBytes());
				} else {
					LOGGER.error("Asset cannot be found!");
					response.setError("Asset cannot be found!");
					response.setResponse(null);
				}

			} else {
				LOGGER.error("Only Auction House can authenticate asset");
				response.setError("Only Auction House can authenticate asset");
				response.setResponse(null);
			}

		} catch (Exception ex) {
			LOGGER.error("Error in updating Art Asset to ledger " + ex.getMessage());
			response.setError(ex.getMessage());
			response.setResponse(null);
		}

		return response;
	}

	/**
	 * The Function to get the content the Art Asset
	 *
	 * @param ctx			Context Chaincode context
	 * @param key   		String key for the asset
	 * @return response		Response<String> Response object with the asset Payload
	 */

	@Transaction()
	public Response<String> queryAssetById(final Context ctx, final String key) {
		Response<String> response = new Response<>();
		try {
			ChaincodeStub stub = ctx.getStub();
			String assetPayload = stub.getStringState(key);
			if (null != assetPayload && !assetPayload.isEmpty()) {
				response.setTransactionId(key);
				response.setResponse(assetPayload);
			} else {
				LOGGER.error("Asset cannot be found!");
				response.setError("Asset cannot be found!");
				response.setResponse(null);
			}
		} catch (Exception ex) {
			LOGGER.error("Error in quering Art Asset from ledger " + ex.getMessage());
			response.setError(ex.getMessage());
			response.setResponse(null);
		}
		return response;
	}

	/**
	 * The Function to get the entire histroy of the Art Asset
	 *
	 * @param ctx			Context Chaincode context
	 * @param key   		String key for the asset
	 * @return response		AssetHistory[] Array of Asset Object to shpw the audit history
	 */

	@Transaction()
	public AssetHistory[] queryAssetHistroy(final Context ctx, final String key) {
		try {
			List<AssetHistory> assetHistories = new ArrayList<AssetHistory>();
			ChaincodeStub stub = ctx.getStub();

			QueryResultsIterator<KeyModification> assetHistorys = stub.getHistoryForKey(key);
			for (KeyModification assetState : assetHistorys) {

				AssetAuthentication asset = genson.deserialize(assetState.getStringValue(), AssetAuthentication.class);
				AssetHistory assetHistory = new AssetHistory(asset, assetState.getTimestamp(), assetState.getTxId());

				assetHistories.add(assetHistory);
			}

			AssetHistory[] response = assetHistories.toArray(new AssetHistory[assetHistories.size()]);
			return response;

		} catch (Exception ex) {
			LOGGER.error("Error in quering Art Asset from ledger " + ex.getMessage());
			return null;
		}

	}

}
