
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;
import "./Ownable.sol";

contract Library is Ownable {

    event LogAddedNewBook(uint bookId);
	event LogBorrowedBook(uint bookId);
	event LogReturnedBook(uint bookId);

    struct Book {
	    uint bookId;
        string title;
        string author;
        uint availableCopies;
    }
	
    Book[] public books ;

    mapping (uint => address[]) public historicalBorrowersByBook;
	
	mapping (uint => address[]) public currentBorrowersByBook;

    function addBook(string calldata title,string calldata author,uint availableCopies) public onlyOwner{
        uint id = books.length;
        books.push(Book(id,title,author,availableCopies));
        emit LogAddedNewBook(id);   
    }
	   
    function listAvailableBooks() public view returns (Book[] memory){
	    Book[] memory result  = new Book[](books.length);
		uint counter = 0;
        for (uint i = 0; i < books.length; i++) {
            if (books[i].availableCopies > 0) {
                result[counter] = books[i];
				counter++;
			}
		}
		return result;
	}

    function checkBookBorrowabilityByAddress(uint bookId,address borrower) public view returns (bool){
    
	    for(uint i=0;i<currentBorrowersByBook[bookId].length;i++){
            if(currentBorrowersByBook[bookId][i] == borrower){
			    return false;
			}
        }
    return true;		
		
    }	
	
	function dropCurrentBorrower(uint bookId,address returner) public {
	
	    for(uint i=0;i<currentBorrowersByBook[bookId].length;i++){
            if(currentBorrowersByBook[bookId][i] == returner){
			    currentBorrowersByBook[bookId][i] = currentBorrowersByBook[bookId][currentBorrowersByBook[bookId].length-1];
				currentBorrowersByBook[bookId].pop;
			}
        }
	}
    

    function _borrowBook(uint _bookId) public{
        // book available copies must be > 0
		require(books[_bookId].availableCopies > 0);
		
		// borrower address must not be in the current borrowers by book mapping
		require(checkBookBorrowabilityByAddress(_bookId,msg.sender));
        
		// add the borrower address to history of borrowers of that book
		historicalBorrowersByBook[_bookId].push(msg.sender);
        
		// add the borrower address to current borrowers of that book
		currentBorrowersByBook[_bookId].push(msg.sender);		
		
		// decrement available copies of this book
		books[_bookId].availableCopies--;
        
		// emit borrowed book
		emit LogBorrowedBook(_bookId);
    }
	
	function returnBook( uint bookId) public{
	    // book returner must be among the current borrowers of that book
		require(!checkBookBorrowabilityByAddress(bookId,msg.sender));
        
		// drop the address of the returner from the current borrowers mapping
		dropCurrentBorrower(bookId,msg.sender);
        
		// increment available copies of that book by one		 
		books[bookId].availableCopies++;
	}
	
	function listHistoricalBorrowers(uint bookId) public view returns (address[] memory){
	    address[] memory result  = new address[](currentBorrowersByBook[bookId].length);
	    uint counter = 0;
	    for (uint i = 0; i < currentBorrowersByBook[bookId].length; i++) {
		    result[counter] = currentBorrowersByBook[bookId][i];
		    counter++;
		}
		return result;
	}

}









