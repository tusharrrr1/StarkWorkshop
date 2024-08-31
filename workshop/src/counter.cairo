// counter contract
#[starknet::interface]
trait ICounter<TContractState> {
    fn get_counter(self: @TContractState) -> u32;
    fn increase_counter(ref self: TContractState, _value: u32);
}

#[starknet::contract]
pub mod Counter {
    use core::starknet::event::EventEmitter;
    use starknet::{get_caller_address, ContractAddress};
    use kill_switch::{IKillSwitchDispatcher, IKillSwitchDispatcherTrait};

    #[storage]
    struct Storage {
        counter: u32,
        kill_switch: ContractAddress
    }

    // this event will emit whenever the state variable counter increases
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    struct CounterIncreased {
       #[key]
       pub value: u32
    }

    // event enum 
    #[event]
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {
        CounterIncreased: CounterIncreased
    }

    #[constructor]
    fn constructor(ref self: ContractState, _counter: u32, _kill_switch: ContractAddress) {
        self.counter.write(_counter);
        self.kill_switch.write(_kill_switch);
    }

    #[abi(embed_v0)]
    impl counter_contract of super::ICounter<ContractState>{
        fn get_counter(self: @ContractState) -> u32 {
            return self.counter.read();
        }

        fn increase_counter(ref self: ContractState, _value: u32) {
            let status: bool = IKillSwitchDispatcher {contract_address: self.kill_switch.read()}.is_active();
            if status == false {
                self.counter.write(_value);
                self.emit(Event::CounterIncreased(CounterIncreased{value: _value}));
            }
        }
    }
}