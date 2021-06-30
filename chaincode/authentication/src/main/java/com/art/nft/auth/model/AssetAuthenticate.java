package com.art.nft.auth.model;

import org.hyperledger.fabric.contract.annotation.DataType;
import org.hyperledger.fabric.contract.annotation.Property;

import com.owlike.genson.annotation.JsonProperty;
@DataType()
public class AssetAuthenticate {
	
	
	@Property()
	private String assetId;
	
	@Property()
	private String authBy;
	
	@Property()
	private String authTs;
	
	@Property()
	private String status;

	public AssetAuthenticate(@JsonProperty("asset_id") String assetId, 
			@JsonProperty("auth_by") String authBy, 
			@JsonProperty("auth_ts") String authTs, 
			@JsonProperty("status")String status) {
		super();
		this.assetId = assetId;
		this.authBy = authBy;
		this.authTs = authTs;
		this.status = status;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((assetId == null) ? 0 : assetId.hashCode());
		result = prime * result + ((authBy == null) ? 0 : authBy.hashCode());
		result = prime * result + ((authTs == null) ? 0 : authTs.hashCode());
		result = prime * result + ((status == null) ? 0 : status.hashCode());
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
		AssetAuthenticate other = (AssetAuthenticate) obj;
		if (assetId == null) {
			if (other.assetId != null)
				return false;
		} else if (!assetId.equals(other.assetId))
			return false;
		if (authBy == null) {
			if (other.authBy != null)
				return false;
		} else if (!authBy.equals(other.authBy))
			return false;
		if (authTs == null) {
			if (other.authTs != null)
				return false;
		} else if (!authTs.equals(other.authTs))
			return false;
		if (status == null) {
			if (other.status != null)
				return false;
		} else if (!status.equals(other.status))
			return false;
		return true;
	}

	public String getAssetId() {
		return assetId;
	}

	public String getAuthBy() {
		return authBy;
	}

	public String getAuthTs() {
		return authTs;
	}

	public String getStatus() {
		return status;
	}

	public void setAssetId(String assetId) {
		this.assetId = assetId;
	}

	public void setAuthBy(String authBy) {
		this.authBy = authBy;
	}

	public void setAuthTs(String authTs) {
		this.authTs = authTs;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	
	
}
