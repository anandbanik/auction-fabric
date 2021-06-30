package com.art.nft.auth.model;

import java.time.Instant;

import org.hyperledger.fabric.contract.annotation.DataType;
import org.hyperledger.fabric.contract.annotation.Property;

import com.owlike.genson.annotation.JsonProperty;

@DataType()
public class AssetHistory {
	
	@Property()
	private AssetAuthentication artAsset;
	
	@Property()
	private Instant txTimestamp;
	
	@Property()
	private String txId;

	public AssetHistory(@JsonProperty("asset") AssetAuthentication artAsset, 
			@JsonProperty("tx_timestamp") Instant txTimestamp, 
			@JsonProperty("tx_id") String txId) {
		super();
		this.artAsset = artAsset;
		this.txTimestamp = txTimestamp;
		this.txId = txId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((artAsset == null) ? 0 : artAsset.hashCode());
		result = prime * result + ((txId == null) ? 0 : txId.hashCode());
		result = prime * result + ((txTimestamp == null) ? 0 : txTimestamp.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		AssetHistory other = (AssetHistory) obj;
		if (artAsset == null) {
			if (other.artAsset != null)
				return false;
		} else if (!artAsset.equals(other.artAsset))
			return false;
		if (txId == null) {
			if (other.txId != null)
				return false;
		} else if (!txId.equals(other.txId))
			return false;
		if (txTimestamp == null) {
			if (other.txTimestamp != null)
				return false;
		} else if (!txTimestamp.equals(other.txTimestamp))
			return false;
		return true;
	}

	public AssetAuthentication getArtAsset() {
		return artAsset;
	}

	public Instant getTxTimestamp() {
		return txTimestamp;
	}

	public String getTxId() {
		return txId;
	}

	public void setArtAsset(AssetAuthentication artAsset) {
		this.artAsset = artAsset;
	}

	public void setTxTimestamp(Instant txTimestamp) {
		this.txTimestamp = txTimestamp;
	}

	public void setTxId(String txId) {
		this.txId = txId;
	}
	
	
}
