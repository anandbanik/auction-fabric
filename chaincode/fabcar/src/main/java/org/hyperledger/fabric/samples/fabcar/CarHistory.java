package org.hyperledger.fabric.samples.fabcar;

import java.time.Instant;

import org.hyperledger.fabric.contract.annotation.DataType;
import org.hyperledger.fabric.contract.annotation.Property;

import com.owlike.genson.annotation.JsonProperty;

@DataType()
public class CarHistory {
	
	@Property()
	private Car car;
	
	@Property()
	private Instant txTimestamp;
	
	@Property()
	private String txId;

	public Car getCar() {
		return car;
	}

	public Instant getTxTimestamp() {
		return txTimestamp;
	}

	public String getTxId() {
		return txId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((car == null) ? 0 : car.hashCode());
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
		CarHistory other = (CarHistory) obj;
		if (car == null) {
			if (other.car != null)
				return false;
		} else if (!car.equals(other.car))
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

	public CarHistory(@JsonProperty("car") final Car car, @JsonProperty("tx_timestamp") final Instant txTimestamp, @JsonProperty("tx_id") final String txId) {
		this.car = car;
		this.txTimestamp = txTimestamp;
		this.txId = txId;
	}

	@Override
	public String toString() {
		return "CarHistory [car=" + car + ", txTimestamp=" + txTimestamp + ", txId=" + txId + "]";
	}

	
	
	

}
