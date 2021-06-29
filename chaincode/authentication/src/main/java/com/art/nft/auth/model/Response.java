package com.art.nft.auth.model;

import org.hyperledger.fabric.contract.annotation.DataType;
import org.hyperledger.fabric.contract.annotation.Property;

import com.owlike.genson.annotation.JsonProperty;

@DataType()
public class Response<T> {

  @Property()
  @JsonProperty("fabric_key")
  private String transactionId;

  @Property()
  @JsonProperty("response")
  private T response;

  @Property()
  @JsonProperty("error")
  private String error;

  public String getTransactionId() {
    return transactionId;
  }

  public void setTransactionId(String transactionId) {
    this.transactionId = transactionId;
  }

  public T getResponse() {
    return response;
  }

  public void setResponse(T response) {
    this.response = response;
  }

  public String getError() {
    return error;
  }

  public void setError(String error) {
    this.error = error;
  }

  @Override
  public String toString() {
    return "Response [transactionId=" + transactionId + ", response=" + response + ", error=" + error + "]";
  }

  @Override
  public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((error == null) ? 0 : error.hashCode());
    result = prime * result + ((response == null) ? 0 : response.hashCode());
    result = prime * result + ((transactionId == null) ? 0 : transactionId.hashCode());
    return result;
  }

  @SuppressWarnings("unchecked")
  @Override
  public boolean equals(Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (getClass() != obj.getClass())
      return false;
    Response<T> other = (Response<T>) obj;
    if (error == null) {
      if (other.error != null)
        return false;
    } else if (!error.equals(other.error))
      return false;
    if (response == null) {
      if (other.response != null)
        return false;
    } else if (!response.equals(other.response))
      return false;
    if (transactionId == null) {
      if (other.transactionId != null)
        return false;
    } else if (!transactionId.equals(other.transactionId))
      return false;
    return true;
  }

  public Response(String transactionId, T response, String error) {
    super();
    this.transactionId = transactionId;
    this.response = response;
    this.error = error;
  }

  public Response() {
    super();
  }
}
