package com.art.nft.auth.contract;

import org.hyperledger.fabric.Logger;
import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.contract.annotation.Contract;
import org.hyperledger.fabric.contract.annotation.Default;
import org.hyperledger.fabric.contract.annotation.Info;
import org.hyperledger.fabric.contract.annotation.Transaction;
import org.hyperledger.fabric.shim.ChaincodeStub;

import com.art.nft.auth.model.AssetAuthentication;
import com.art.nft.auth.model.Response;
import com.art.nft.auth.util.AuthenticationConstants;
import com.owlike.genson.Genson;

@Contract(name = "authentication-chaincode", info = @Info(title = "Authentication Contract", description = "Auction-House Authentication Smart-Contract", version = "1.0.0"))
@Default
public class AuctionAuthentication implements ContractInterface {

	private static final Logger LOGGER = Logger.getLogger(AuctionAuthentication.class);
	private final Genson genson = new Genson();

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
				String strAuthAsset = genson.serialize(assetAuthentication);
				stub.putStringState(key, strAuthAsset);
				response.setResponse(strAuthAsset);
				stub.setEvent("asset_created#ID"+key, strAuthAsset.getBytes());
			} else {
				LOGGER.error("Only Auction House can create asset");
				response.setError("Only Auction House can create asset");
				response.setResponse(null);
			}

		} catch (Exception ex) {
			LOGGER.error("Error in adding PO trace event to ledger " + ex.getMessage());
			response.setError(ex.getMessage());
			response.setResponse(null);
		}

		return response;
	}
	
	@Transaction()
	public Response<String> authenticateAsset(final Context ctx, final String assetPayload) {
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
				String strAuthAsset = genson.serialize(assetAuthentication);
				stub.putStringState(key, strAuthAsset);
				response.setResponse(strAuthAsset);
				stub.setEvent("asset_created#ID"+key, strAuthAsset.getBytes());
			} else {
				LOGGER.error("Only Auction House can create asset");
				response.setError("Only Auction House can create asset");
				response.setResponse(null);
			}

		} catch (Exception ex) {
			LOGGER.error("Error in adding PO trace event to ledger " + ex.getMessage());
			response.setError(ex.getMessage());
			response.setResponse(null);
		}

		return response;
	}

}
