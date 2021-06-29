package com.art.nft.auth.model;

import org.hyperledger.fabric.contract.annotation.DataType;
import org.hyperledger.fabric.contract.annotation.Property;

import com.owlike.genson.annotation.JsonProperty;

@DataType()
public class AssetAuthentication {

	@Property()
	private String name;

	@Property()
	private String description;

	@Property()
	private String creator;

	@Property()
	private String location;

	@Property()
	private Double size;

	@Property()
	private String uom;

	@Property()
	private Integer createYear;

	@Property()
	private String references;

	@Property()
	private String comments;

	@Property()
	private String status;

	@Property()
	private String authBy;

	@Property()
	private String authTs;

	public AssetAuthentication(@JsonProperty("name") String name, 
			@JsonProperty("description") String description, 
			@JsonProperty("creator") String creator, 
			@JsonProperty("location") String location, 
			@JsonProperty("size") Double size,
			@JsonProperty("uom") String uom, 
			@JsonProperty("create_year") Integer createYear, 
			@JsonProperty("references") String references, 
			@JsonProperty("comments") String comments, 
			@JsonProperty("status") String status, 
			@JsonProperty("authBy") String authBy,
			@JsonProperty("authTs") String authTs) {
		super();
		this.name = name;
		this.description = description;
		this.creator = creator;
		this.location = location;
		this.size = size;
		this.uom = uom;
		this.createYear = createYear;
		this.references = references;
		this.comments = comments;
		this.status = status;
		this.authBy = authBy;
		this.authTs = authTs;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((authBy == null) ? 0 : authBy.hashCode());
		result = prime * result + ((authTs == null) ? 0 : authTs.hashCode());
		result = prime * result + ((comments == null) ? 0 : comments.hashCode());
		result = prime * result + ((createYear == null) ? 0 : createYear.hashCode());
		result = prime * result + ((creator == null) ? 0 : creator.hashCode());
		result = prime * result + ((description == null) ? 0 : description.hashCode());
		result = prime * result + ((location == null) ? 0 : location.hashCode());
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + ((references == null) ? 0 : references.hashCode());
		result = prime * result + ((size == null) ? 0 : size.hashCode());
		result = prime * result + ((status == null) ? 0 : status.hashCode());
		result = prime * result + ((uom == null) ? 0 : uom.hashCode());
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
		AssetAuthentication other = (AssetAuthentication) obj;
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
		if (comments == null) {
			if (other.comments != null)
				return false;
		} else if (!comments.equals(other.comments))
			return false;
		if (createYear == null) {
			if (other.createYear != null)
				return false;
		} else if (!createYear.equals(other.createYear))
			return false;
		if (creator == null) {
			if (other.creator != null)
				return false;
		} else if (!creator.equals(other.creator))
			return false;
		if (description == null) {
			if (other.description != null)
				return false;
		} else if (!description.equals(other.description))
			return false;
		if (location == null) {
			if (other.location != null)
				return false;
		} else if (!location.equals(other.location))
			return false;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		if (references == null) {
			if (other.references != null)
				return false;
		} else if (!references.equals(other.references))
			return false;
		if (size == null) {
			if (other.size != null)
				return false;
		} else if (!size.equals(other.size))
			return false;
		if (status == null) {
			if (other.status != null)
				return false;
		} else if (!status.equals(other.status))
			return false;
		if (uom == null) {
			if (other.uom != null)
				return false;
		} else if (!uom.equals(other.uom))
			return false;
		return true;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getCreator() {
		return creator;
	}

	public void setCreator(String creator) {
		this.creator = creator;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public Double getSize() {
		return size;
	}

	public void setSize(Double size) {
		this.size = size;
	}

	public String getUom() {
		return uom;
	}

	public void setUom(String uom) {
		this.uom = uom;
	}

	public Integer getCreateYear() {
		return createYear;
	}

	public void setCreateYear(Integer createYear) {
		this.createYear = createYear;
	}

	public String getReferences() {
		return references;
	}

	public void setReferences(String references) {
		this.references = references;
	}

	public String getComments() {
		return comments;
	}

	public void setComments(String comments) {
		this.comments = comments;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getAuthBy() {
		return authBy;
	}

	public void setAuthBy(String authBy) {
		this.authBy = authBy;
	}

	public String getAuthTs() {
		return authTs;
	}

	public void setAuthTs(String authTs) {
		this.authTs = authTs;
	}

	@Override
	public String toString() {
		return "AssetAuthentication [name=" + name + ", description=" + description + ", creator=" + creator
				+ ", location=" + location + ", size=" + size + ", uom=" + uom + ", createYear=" + createYear
				+ ", references=" + references + ", comments=" + comments + ", status=" + status + ", authBy=" + authBy
				+ ", authTs=" + authTs + "]";
	}
	
	

}
