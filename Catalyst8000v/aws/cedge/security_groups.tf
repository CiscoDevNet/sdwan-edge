/*
  Security Groups
*/


resource "aws_security_group" "transport" {

    vpc_id = data.aws_vpc.instance.id
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }    
        
    ingress {
        from_port 	= 443  # allow https
        to_port 	= 443
        protocol 	= "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }    


    ingress {
        from_port 	= 22   # allow ssh
        to_port 	= 22
        protocol 	= "tcp"        
        cidr_blocks = ["0.0.0.0/0"]
    }   

    ingress {
        from_port 	= 8    # allow ping
        to_port 	= 0
        protocol 	= "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }


    ingress {
        from_port 	= 830  # allow Netconf
        to_port 	= 830
        protocol 	= "tcp"        
        cidr_blocks = ["0.0.0.0/0"]
    }    

    ingress {
        from_port 	= 12346  # allow dtls
        to_port 	= 13156
        protocol 	= "udp"        
        cidr_blocks = ["0.0.0.0/0"]
    }   

    ingress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        self 	  = "true"
    } 

    tags = {
      Name = "sdwan - transport"
    }
}

resource "aws_security_group" "service" {

    vpc_id = data.aws_vpc.instance.id

    egress {
        from_port   = 0
        to_port 	= 0
        protocol 	= -1
        cidr_blocks	= ["0.0.0.0/0"]
    }

    ingress {
        from_port 	= 0
        to_port 	= 0
        protocol 	= "-1"        
        cidr_blocks = ["0.0.0.0/0"]
    }   

    tags = {
      Name = "sdwan - service"
    }
}

