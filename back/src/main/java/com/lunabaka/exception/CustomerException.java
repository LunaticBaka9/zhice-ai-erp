package com.lunabaka.exception;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class CustomerException extends RuntimeException{
    private String code;
    private String msg;

    public CustomerException(String code, String msg){
        this.code = code;
        this.msg = msg;
    }

    public CustomerException(String msg){
        this.code = "500";
        this.msg = msg;
    }

    public CustomerException(){}

}
